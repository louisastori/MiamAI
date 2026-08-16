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
    void cheaperCommandSelectsLowerCostAlternativesForActiveBasket() {
        ChatResponse initial = assistantService.chat(new ChatRequest(null, "Je veux manger asiatique pour 3 personnes"));
        recipeService.selectRecipe(initial.proposals().getFirst().id(), 3);
        Basket basket = basketService.buildSelectedBasket();

        ChatResponse cheaper = assistantService.chat(new ChatRequest(initial.sessionId(), "Prends moins cher"));

        assertThat(basket.totalPrice()).isEqualByComparingTo(new BigDecimal("13.81"));
        assertThat(cheaper.basket()).isNotNull();
        assertThat(cheaper.basket().totalPrice()).isLessThan(basket.totalPrice());
    }
}
