package com.miamai.api.preference;

import jakarta.validation.Valid;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;
import java.util.List;
import java.util.Set;

public record PreferenceProfile(
        @Valid @NotNull LeclercDrive preferredDrive,
        @Min(1) int peopleCount,
        @DecimalMin("0.0") BigDecimal weeklyBudget,
        @NotBlank String defaultDietMode,
        Set<String> dietaryRestrictions,
        List<String> excludedIngredients,
        Set<String> kitchenEquipment,
        boolean planningReminders,
        boolean leclercPromotions
) {
    public static PreferenceProfile defaultProfile() {
        return new PreferenceProfile(
                new LeclercDrive("leclerc-pessac", "Pessac", "Avenue Gutenberg, 33600 Pessac"),
                3,
                new BigDecimal("60.00"),
                "Équilibré",
                Set.of(),
                List.of(),
                Set.of(),
                true,
                false
        );
    }
}
