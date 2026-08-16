package com.miamai.api.recipe;

import jakarta.validation.constraints.Min;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

public record UpdateRecipeRequest(
        @Min(1) Integer servings,
        BigDecimal budget,
        List<String> removeIngredients,
        Map<String, String> replacements
) {
}
