package com.miamai.api.meal;

import java.util.List;

public record MealPlanItem(
        String day,
        String recipeId,
        String title,
        int prepTimeMinutes,
        List<String> ingredientTags,
        boolean selected
) {
}
