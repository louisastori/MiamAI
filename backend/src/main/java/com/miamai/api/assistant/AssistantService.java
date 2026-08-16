package com.miamai.api.assistant;

import com.miamai.api.basket.Basket;
import com.miamai.api.basket.BasketService;
import com.miamai.api.preference.PreferenceService;
import com.miamai.api.recipe.RecipeDetail;
import com.miamai.api.recipe.RecipeProposal;
import com.miamai.api.recipe.RecipeService;
import com.miamai.api.recipe.UpdateRecipeRequest;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class AssistantService {

    // Orchestrateur IA simulé pour le MVP : il transforme quelques phrases clés
    // en actions déterministes sur les recettes et le panier.
    private final RecipeService recipeService;
    private final BasketService basketService;
    private final PreferenceService preferenceService;
    private final Map<String, SessionState> sessions = new HashMap<>();

    public AssistantService(
            RecipeService recipeService,
            BasketService basketService,
            PreferenceService preferenceService
    ) {
        this.recipeService = recipeService;
        this.basketService = basketService;
        this.preferenceService = preferenceService;
    }

    public ChatResponse chat(ChatRequest request) {
        String sessionId = request.sessionId() == null || request.sessionId().isBlank()
                ? UUID.randomUUID().toString()
                : request.sessionId();
        SessionState state = sessions.computeIfAbsent(sessionId, ignored -> new SessionState());
        String message = request.message();
        String normalized = normalize(message);
        boolean hasActiveRecipe = state.selectedRecipeId != null
                || state.basketId != null
                || recipeService.hasSelectedRecipe();

        if (normalized.contains("moins cher") || (hasActiveRecipe && normalized.contains("petit budget"))) {
            Basket basket = state.basketId == null
                    ? basketService.selectCheapestProducts(basketService.buildSelectedBasket().id())
                    : basketService.selectCheapestProducts(state.basketId);
            state.selectedRecipeId = basket.recipeId();
            state.basketId = basket.id();
            return new ChatResponse(
                    sessionId,
                    "J'ai sélectionné les alternatives les moins chères disponibles dans le Drive choisi.",
                    List.of(),
                    recipeService.selectedRecipe(),
                    basket
            );
        }

        Integer servings = extractServingCount(normalized);
        boolean asksForServingUpdate = normalized.contains("finalement")
                || normalized.contains("sera")
                || normalized.contains("sommes")
                || normalized.contains("on est");
        if (servings != null && hasActiveRecipe && asksForServingUpdate) {
            RecipeDetail recipe = recipeService.updateSelectedRecipe(new UpdateRecipeRequest(servings, null, List.of(), Map.of()));
            Basket basket = basketService.buildBasket(recipe);
            state.selectedRecipeId = recipe.id();
            state.basketId = basket.id();
            return new ChatResponse(
                    sessionId,
                    "C'est recalculé pour " + servings + " personnes.",
                    List.of(),
                    recipe,
                    basket
            );
        }

        Map<String, String> replacements = extractReplacement(normalized);
        if (hasActiveRecipe && !replacements.isEmpty()) {
            RecipeDetail recipe = recipeService.updateSelectedRecipe(new UpdateRecipeRequest(null, null, List.of(), replacements));
            Basket basket = basketService.buildBasket(recipe);
            state.selectedRecipeId = recipe.id();
            state.basketId = basket.id();
            return new ChatResponse(
                    sessionId,
                    "J'ai appliqué le remplacement et recalculé le panier.",
                    List.of(),
                    recipe,
                    basket
            );
        }

        List<String> removals = extractRemovals(normalized);
        if (hasActiveRecipe && !removals.isEmpty()) {
            RecipeDetail recipe = recipeService.updateSelectedRecipe(new UpdateRecipeRequest(null, null, removals, Map.of()));
            Basket basket = basketService.buildBasket(recipe);
            state.selectedRecipeId = recipe.id();
            state.basketId = basket.id();
            return new ChatResponse(
                    sessionId,
                    "C'est noté, j'ai retiré l'ingrédient demandé et recalculé le panier.",
                    List.of(),
                    recipe,
                    basket
            );
        }

        List<RecipeProposal> proposals = recipeService.proposeRecipes(message, preferenceService.currentProfile());
        return new ChatResponse(
                sessionId,
                "Je vous propose ces 3 recettes faciles à réaliser :",
                proposals,
                null,
                null
        );
    }

    private Integer extractServingCount(String normalized) {
        // Les commandes vocales ou chat peuvent dire "4 personnes", "4 personne"
        // ou simplement "4 pers".
        Matcher matcher = Pattern.compile("(\\d+)\\s*(personnes|personne|pers)").matcher(normalized);
        if (matcher.find()) {
            return Integer.parseInt(matcher.group(1));
        }
        return null;
    }

    private Map<String, String> extractReplacement(String normalized) {
        // Format volontairement simple pour la simulation :
        // "remplace le poulet par de la dinde".
        Matcher matcher = Pattern.compile("remplace\\s+(?:le|la|les)?\\s*([a-z\\- ]+)\\s+par\\s+(?:de la|du|des|de l'|de)?\\s*([a-z\\- ]+)").matcher(normalized);
        if (!matcher.find()) {
            return Map.of();
        }
        String source = matcher.group(1).trim();
        String target = matcher.group(2).trim();
        if (source.isBlank() || target.isBlank()) {
            return Map.of();
        }
        return Map.of(source, titleCase(target));
    }

    private List<String> extractRemovals(String normalized) {
        Matcher matcher = Pattern.compile("(?:enleve|retire|supprime)\\s+(?:le|la|les)?\\s*([a-z\\- ]+)").matcher(normalized);
        if (!matcher.find()) {
            return List.of();
        }
        String removal = matcher.group(1).trim();
        return removal.isBlank() ? List.of() : List.of(removal);
    }

    private String normalize(String message) {
        // Normalisation minimale pour parser les commandes sans dépendre
        // d'un vrai modèle IA pendant la première tranche.
        return message.toLowerCase(Locale.ROOT)
                .replace("è", "e")
                .replace("é", "e")
                .replace("ê", "e")
                .replace("à", "a")
                .replace("ç", "c");
    }

    private String titleCase(String value) {
        if (value.isBlank()) {
            return value;
        }
        return value.substring(0, 1).toUpperCase(Locale.ROOT) + value.substring(1);
    }

    private static class SessionState {
        private String selectedRecipeId;
        private String basketId;
    }
}
