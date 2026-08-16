package com.miamai.api;

import com.miamai.api.assistant.AssistantService;
import com.miamai.api.assistant.ChatRequest;
import com.miamai.api.assistant.ChatResponse;
import com.miamai.api.basket.Basket;
import com.miamai.api.basket.BasketLine;
import com.miamai.api.basket.BasketService;
import com.miamai.api.recipe.IngredientRequirement;
import com.miamai.api.recipe.RecipeDetail;
import com.miamai.api.recipe.RecipeService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
class MiamAiFlowTests {

    @Autowired
    private AssistantService assistantService;

    @Autowired
    private RecipeService recipeService;

    @Autowired
    private BasketService basketService;

    @Test
    void initialPromptWithServingsReturnsRecipeProposals() {
        ChatResponse response = assistantService.chat(new ChatRequest(
                null,
                "Je veux manger asiatique ce soir, pour 3 personnes, pas trop complique."
        ));

        assertThat(response.sessionId()).isNotBlank();
        assertThat(response.proposals()).hasSize(3);
        assertThat(response.selectedRecipe()).isNull();
        assertThat(response.basket()).isNull();
        assertThat(response.proposals().getFirst().title()).contains("Poulet");
    }

    @Test
    void promptWithBudgetFiltersRecipeProposals() {
        ChatResponse response = assistantService.chat(new ChatRequest(
                null,
                "Je veux un repas asiatique pour 3 personnes, rapide et a moins de 15 euros."
        ));

        assertThat(response.proposals()).isNotEmpty();
        assertThat(response.proposals())
                .allSatisfy(recipe -> assertThat(recipe.estimatedCost()).isLessThanOrEqualTo(new BigDecimal("15.00")));
        assertThat(response.proposals())
                .extracting("id")
                .doesNotContain("boeuf-teriyaki");
    }

    @Test
    void recipeScalingUpdatesIngredientQuantities() {
        RecipeDetail scaled = recipeService.getRecipe("poulet-yakitori").withServings(4);

        IngredientRequirement chicken = scaled.ingredients().stream()
                .filter(ingredient -> ingredient.key().equals("poulet"))
                .findFirst()
                .orElseThrow();

        assertThat(scaled.servings()).isEqualTo(4);
        assertThat(chicken.quantity()).isEqualByComparingTo(new BigDecimal("800"));
        assertThat(scaled.estimatedBasketCost()).isEqualByComparingTo(new BigDecimal("15.73"));
    }

    @Test
    void basketMatchesLeclercProductsAndCalculatesTotals() {
        Basket basket = basketService.buildBasket("poulet-yakitori", 3);

        assertThat(basket.valid()).isTrue();
        assertThat(basket.lines()).hasSize(5);
        assertThat(basket.totalPrice()).isEqualByComparingTo(new BigDecimal("13.81"));

        BasketLine chicken = basket.lines().stream()
                .filter(line -> line.ingredientKey().equals("poulet"))
                .findFirst()
                .orElseThrow();

        assertThat(chicken.selectedProduct().title()).isEqualTo("Filets de poulet 650g");
        assertThat(chicken.packageCount()).isEqualTo(1);
        assertThat(chicken.overageQuantity()).isEqualByComparingTo(new BigDecimal("50"));
    }

    @Test
    void selectingProductAlternativeRecalculatesBasketTotal() {
        Basket basket = basketService.buildBasket("poulet-yakitori", 3);

        Basket updated = basketService.selectProduct(basket.id(), "riz", "LEC-RIZ-ECO-1K");
        BasketLine rice = updated.lines().stream()
                .filter(line -> line.ingredientKey().equals("riz"))
                .findFirst()
                .orElseThrow();

        assertThat(rice.selectedProduct().title()).isEqualTo("Riz long grain 1kg");
        assertThat(updated.totalPrice()).isEqualByComparingTo(new BigDecimal("13.27"));
        assertThat(updated.totalPrice()).isLessThan(basket.totalPrice());
    }

    @Test
    void cheaperCommandSelectsLowerCostAlternativesForActiveBasket() {
        ChatResponse initial = assistantService.chat(new ChatRequest(null, "Je veux manger asiatique pour 3 personnes"));
        recipeService.selectRecipe(initial.proposals().getFirst().id(), 3);
        Basket basket = basketService.buildSelectedBasket();

        ChatResponse cheaper = assistantService.chat(new ChatRequest(initial.sessionId(), "Prends moins cher"));

        assertThat(basket.totalPrice()).isEqualByComparingTo(new BigDecimal("13.81"));
        assertThat(cheaper.basket()).isNotNull();
        assertThat(cheaper.basket().totalPrice()).isLessThan(basket.totalPrice());
    }

    @Test
    void replacementCommandAfterRecipeSelectionRebuildsBasket() {
        ChatResponse initial = assistantService.chat(new ChatRequest(null, "Je veux manger asiatique pour 3 personnes"));
        recipeService.selectRecipe(initial.proposals().getFirst().id(), 3);

        ChatResponse response = assistantService.chat(new ChatRequest(
                initial.sessionId(),
                "Remplace le poulet par de la dinde"
        ));

        assertThat(response.selectedRecipe()).isNotNull();
        assertThat(response.selectedRecipe().ingredients())
                .extracting(IngredientRequirement::name)
                .contains("Dinde")
                .doesNotContain("Poulet");
        assertThat(response.basket()).isNotNull();
        assertThat(response.basket().lines())
                .filteredOn(line -> line.ingredientKey().equals("dinde"))
                .singleElement()
                .satisfies(line -> assertThat(line.selectedProduct().title()).isEqualTo("Escalopes de dinde 600g"));
        assertThat(response.basket().totalPrice()).isEqualByComparingTo(new BigDecimal("13.21"));
    }

    @Test
    void servingAndRemovalCommandsRecalculateSelectedRecipeAndBasket() {
        ChatResponse initial = assistantService.chat(new ChatRequest(null, "Je veux manger asiatique pour 3 personnes"));
        recipeService.selectRecipe(initial.proposals().getFirst().id(), 3);

        ChatResponse resized = assistantService.chat(new ChatRequest(initial.sessionId(), "On sera finalement 4 personnes"));
        ChatResponse withoutSesame = assistantService.chat(new ChatRequest(initial.sessionId(), "Enleve les graines de sesame"));

        assertThat(resized.selectedRecipe()).isNotNull();
        assertThat(resized.selectedRecipe().servings()).isEqualTo(4);
        assertThat(resized.basket()).isNotNull();
        assertThat(resized.basket().totalPrice()).isEqualByComparingTo(new BigDecimal("20.30"));

        assertThat(withoutSesame.selectedRecipe()).isNotNull();
        assertThat(withoutSesame.selectedRecipe().servings()).isEqualTo(4);
        assertThat(withoutSesame.selectedRecipe().ingredients())
                .extracting(IngredientRequirement::key)
                .doesNotContain("graines-sesame");
        assertThat(withoutSesame.basket()).isNotNull();
        assertThat(withoutSesame.basket().totalPrice()).isEqualByComparingTo(new BigDecimal("18.91"));
    }
}
