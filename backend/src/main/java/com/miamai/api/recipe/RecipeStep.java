package com.miamai.api.recipe;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record RecipeStep(
        @Min(1) int order,
        @NotBlank String text
) {
}
