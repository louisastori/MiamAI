package com.miamai.api.recipe;

import jakarta.validation.constraints.Min;

public record Nutrition(
        @Min(0) int caloriesKcal,
        @Min(0) int proteinGrams,
        @Min(0) int carbsGrams,
        @Min(0) int fatGrams
) {
}
