package com.miamai.api.recipe;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

public record IngredientRequirement(
        @NotBlank String key,
        @NotBlank String name,
        @DecimalMin("0.0") BigDecimal quantity,
        @NotBlank String unit,
        boolean scalable,
        List<String> replacementHints
) {
    public IngredientRequirement scaled(double factor) {
        // Certains éléments, comme une bouteille de sauce, ne changent pas
        // automatiquement quand on ajuste le nombre de personnes.
        if (!scalable) {
            return this;
        }
        BigDecimal scaledQuantity = quantity
                .multiply(BigDecimal.valueOf(factor))
                .setScale(0, RoundingMode.HALF_UP);
        return new IngredientRequirement(key, name, scaledQuantity, unit, true, replacementHints);
    }
}
