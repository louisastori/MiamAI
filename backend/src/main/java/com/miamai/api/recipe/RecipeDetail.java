package com.miamai.api.recipe;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

public record RecipeDetail(
        String id,
        String title,
        String description,
        String cuisine,
        int baseServings,
        int servings,
        int prepTimeMinutes,
        BigDecimal estimatedBasketCost,
        String imageUrl,
        String nutriScore,
        Nutrition nutrition,
        List<IngredientRequirement> ingredients,
        List<RecipeStep> steps,
        List<String> chefTips,
        List<String> tags
) {
    public RecipeDetail withServings(int nextServings) {
        if (nextServings < 1) {
            throw new IllegalArgumentException("Le nombre de personnes doit être supérieur à 0");
        }
        double factor = (double) nextServings / (double) baseServings;
        BigDecimal nextCost = estimatedBasketCost
                .multiply(BigDecimal.valueOf(factor))
                .setScale(2, RoundingMode.HALF_UP);
        return new RecipeDetail(
                id,
                title,
                description,
                cuisine,
                baseServings,
                nextServings,
                prepTimeMinutes,
                nextCost,
                imageUrl,
                nutriScore,
                nutrition,
                ingredients.stream().map(ingredient -> ingredient.scaled(factor)).toList(),
                steps,
                chefTips,
                tags
        );
    }
}
