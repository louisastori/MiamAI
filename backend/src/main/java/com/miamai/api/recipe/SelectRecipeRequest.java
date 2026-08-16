package com.miamai.api.recipe;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record SelectRecipeRequest(
        @NotBlank String recipeId,
        @Min(1) Integer servings
) {
}
