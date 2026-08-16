package com.miamai.api.recipe;

import java.math.BigDecimal;
import java.util.List;

public record RecipeProposal(
        String id,
        String title,
        String description,
        String cuisine,
        int servings,
        int prepTimeMinutes,
        BigDecimal estimatedCost,
        String imageUrl,
        String nutriScore,
        List<String> tags
) {
}
