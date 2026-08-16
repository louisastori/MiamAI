package com.miamai.api.recipe;

import com.miamai.api.preference.PreferenceProfile;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.concurrent.atomic.AtomicReference;

@Service
public class RecipeService {

    private static final String YAKITORI_IMAGE = "https://images.unsplash.com/photo-1525755662778-989d0524087e";
    private static final String CURRY_IMAGE = "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd";
    private static final String TERIYAKI_IMAGE = "https://images.unsplash.com/photo-1617093727343-374698b1b08d";

    private final Map<String, RecipeDetail> recipes = new LinkedHashMap<>();
    private final AtomicReference<RecipeDetail> selectedRecipe = new AtomicReference<>();

    public RecipeService() {
        seedRecipes();
    }

    public List<RecipeProposal> proposeRecipes(String prompt, PreferenceProfile preferences) {
        // La simulation lit seulement le nombre de personnes. Le futur fournisseur IA
        // utilisera aussi le budget, le temps, les exclusions et le type de cuisine.
        int servings = extractServings(prompt, preferences.peopleCount());
        return recipes.values().stream()
                .map(recipe -> recipe.withServings(servings))
                .map(this::toProposal)
                .toList();
    }

    public RecipeDetail getRecipe(String recipeId) {
        RecipeDetail recipe = recipes.get(recipeId);
        if (recipe == null) {
            throw new IllegalArgumentException("Recette inconnue : " + recipeId);
        }
        return recipe;
    }

    public RecipeDetail selectRecipe(String recipeId, Integer servings) {
        RecipeDetail recipe = getRecipe(recipeId);
        RecipeDetail selected = servings == null ? recipe : recipe.withServings(servings);
        selectedRecipe.set(selected);
        return selected;
    }

    public RecipeDetail selectedRecipe() {
        RecipeDetail selected = selectedRecipe.get();
        if (selected == null) {
            return selectRecipe("poulet-yakitori", 3);
        }
        return selected;
    }

    public RecipeDetail updateSelectedRecipe(UpdateRecipeRequest request) {
        RecipeDetail current = selectedRecipe();
        RecipeDetail updated = request.servings() == null ? current : current.withServings(request.servings());

        if (request.removeIngredients() != null && !request.removeIngredients().isEmpty()) {
            List<String> removals = request.removeIngredients().stream()
                    .map(value -> value.toLowerCase(Locale.ROOT))
                    .toList();
            List<IngredientRequirement> ingredients = updated.ingredients().stream()
                    .filter(ingredient -> removals.stream().noneMatch(removal ->
                            ingredient.name().toLowerCase(Locale.ROOT).contains(removal)
                                    || ingredient.key().toLowerCase(Locale.ROOT).contains(removal)))
                    .toList();
            updated = new RecipeDetail(
                    updated.id(),
                    updated.title(),
                    updated.description(),
                    updated.cuisine(),
                    updated.baseServings(),
                    updated.servings(),
                    updated.prepTimeMinutes(),
                    updated.estimatedBasketCost(),
                    updated.imageUrl(),
                    updated.nutriScore(),
                    updated.nutrition(),
                    ingredients,
                    updated.steps(),
                    updated.chefTips(),
                    updated.tags()
            );
        }

        if (request.replacements() != null && !request.replacements().isEmpty()) {
            Map<String, String> replacements = request.replacements();
            List<IngredientRequirement> ingredients = updated.ingredients().stream()
                    .map(ingredient -> replaceIngredient(ingredient, replacements))
                    .toList();
            updated = new RecipeDetail(
                    updated.id(),
                    updated.title(),
                    updated.description(),
                    updated.cuisine(),
                    updated.baseServings(),
                    updated.servings(),
                    updated.prepTimeMinutes(),
                    updated.estimatedBasketCost(),
                    updated.imageUrl(),
                    updated.nutriScore(),
                    updated.nutrition(),
                    ingredients,
                    updated.steps(),
                    updated.chefTips(),
                    updated.tags()
            );
        }

        selectedRecipe.set(updated);
        return updated;
    }

    private IngredientRequirement replaceIngredient(IngredientRequirement ingredient, Map<String, String> replacements) {
        for (Map.Entry<String, String> replacement : replacements.entrySet()) {
            String source = replacement.getKey().toLowerCase(Locale.ROOT);
            if (ingredient.name().toLowerCase(Locale.ROOT).contains(source)
                    || ingredient.key().toLowerCase(Locale.ROOT).contains(source)) {
                String replacementName = replacement.getValue();
                String key = replacementName.toLowerCase(Locale.ROOT)
                        .replace(" ", "-")
                        .replace("'", "");
                return new IngredientRequirement(
                        key,
                        replacementName,
                        ingredient.quantity(),
                        ingredient.unit(),
                        ingredient.scalable(),
                        ingredient.replacementHints()
                );
            }
        }
        return ingredient;
    }

    private RecipeProposal toProposal(RecipeDetail recipe) {
        return new RecipeProposal(
                recipe.id(),
                recipe.title(),
                recipe.description(),
                recipe.cuisine(),
                recipe.servings(),
                recipe.prepTimeMinutes(),
                recipe.estimatedBasketCost(),
                recipe.imageUrl(),
                recipe.nutriScore(),
                recipe.tags()
        );
    }

    private int extractServings(String prompt, int fallback) {
        if (prompt == null || prompt.isBlank()) {
            return fallback;
        }
        String normalized = prompt.toLowerCase(Locale.ROOT);
        for (int count = 1; count <= 12; count++) {
            if (normalized.contains(count + " personne") || normalized.contains(count + " pers")) {
                return count;
            }
        }
        return fallback;
    }

    private void seedRecipes() {
        recipes.put("poulet-yakitori", new RecipeDetail(
                "poulet-yakitori",
                "Poulet yakitori",
                "Brochettes de poulet glacées, riz basmati et légumes croquants.",
                "Asiatique",
                3,
                3,
                30,
                new BigDecimal("11.80"),
                YAKITORI_IMAGE,
                "A",
                new Nutrition(320, 35, 15, 12),
                List.of(
                        new IngredientRequirement("poulet", "Poulet", new BigDecimal("600"), "g", true, List.of("Dinde", "Tofu")),
                        new IngredientRequirement("riz", "Riz", new BigDecimal("300"), "g", true, List.of("Nouilles soba")),
                        new IngredientRequirement("sauce-yakitori", "Sauce yakitori", BigDecimal.ONE, "bouteille", false, List.of("Sauce soja")),
                        new IngredientRequirement("oignons-nouveaux", "Oignons nouveaux", new BigDecimal("2"), "pièces", true, List.of("Ciboulette")),
                        new IngredientRequirement("graines-sesame", "Graines de sésame", new BigDecimal("30"), "g", true, List.of())
                ),
                List.of(
                        new RecipeStep(1, "Couper le poulet en cubes réguliers pour assurer une cuisson homogène."),
                        new RecipeStep(2, "Monter les brochettes en alternant les morceaux de poulet et les tronçons d'oignons nouveaux."),
                        new RecipeStep(3, "Faire cuire sur un gril ou à la poêle, en badigeonnant de sauce yakitori et en saupoudrant de sésame en fin de cuisson.")
                ),
                List.of(
                        "Faites tremper les piques en bois dans l'eau pendant 10 minutes avant la cuisson.",
                        "Faites mariner le poulet dans un peu de sauce soja pour encore plus de saveur."
                ),
                List.of("Rapide", "Petit budget", "Asiatique")
        ));

        recipes.put("curry-thai-poulet", new RecipeDetail(
                "curry-thai-poulet",
                "Curry Thaï vert au poulet",
                "Curry au lait de coco, poivrons et riz jasmin.",
                "Asiatique",
                3,
                3,
                35,
                new BigDecimal("15.00"),
                CURRY_IMAGE,
                "B",
                new Nutrition(470, 31, 48, 18),
                List.of(
                        new IngredientRequirement("poulet", "Poulet", new BigDecimal("500"), "g", true, List.of("Dinde", "Tofu")),
                        new IngredientRequirement("lait-coco", "Lait de coco", BigDecimal.ONE, "brique", false, List.of()),
                        new IngredientRequirement("riz", "Riz jasmin", new BigDecimal("300"), "g", true, List.of("Riz basmati")),
                        new IngredientRequirement("poivrons", "Poivrons", new BigDecimal("2"), "pièces", true, List.of())
                ),
                List.of(
                        new RecipeStep(1, "Saisir le poulet en morceaux."),
                        new RecipeStep(2, "Ajouter la pâte de curry, le lait de coco et les poivrons."),
                        new RecipeStep(3, "Servir avec le riz cuit.")
                ),
                List.of("Dosez la pâte de curry selon le niveau de piquant souhaité."),
                List.of("Asiatique", "Réconfortant")
        ));

        recipes.put("boeuf-teriyaki", new RecipeDetail(
                "boeuf-teriyaki",
                "Boeuf teriyaki, brocolis et nouilles soba",
                "Sauté rapide au bœuf, légumes croquants et sauce teriyaki.",
                "Asiatique",
                3,
                3,
                30,
                new BigDecimal("17.00"),
                TERIYAKI_IMAGE,
                "B",
                new Nutrition(520, 38, 51, 19),
                List.of(
                        new IngredientRequirement("boeuf", "Bœuf", new BigDecimal("450"), "g", true, List.of("Poulet")),
                        new IngredientRequirement("nouilles-soba", "Nouilles soba", new BigDecimal("300"), "g", true, List.of("Riz")),
                        new IngredientRequirement("brocolis", "Brocolis", new BigDecimal("500"), "g", true, List.of("Haricots verts")),
                        new IngredientRequirement("sauce-teriyaki", "Sauce teriyaki", BigDecimal.ONE, "bouteille", false, List.of("Sauce soja"))
                ),
                List.of(
                        new RecipeStep(1, "Saisir le bœuf à feu vif."),
                        new RecipeStep(2, "Ajouter brocolis, nouilles et sauce teriyaki."),
                        new RecipeStep(3, "Mélanger jusqu'à ce que la sauce nappe les ingrédients.")
                ),
                List.of("Coupez le bœuf très fin pour garder une cuisson rapide."),
                List.of("Asiatique", "Protéiné")
        ));
    }
}
