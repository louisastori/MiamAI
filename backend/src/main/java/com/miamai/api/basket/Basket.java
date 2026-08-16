package com.miamai.api.basket;

import java.math.BigDecimal;
import java.util.List;

public record Basket(
        String id,
        String recipeId,
        String recipeTitle,
        String heroImageUrl,
        String driveId,
        List<BasketLine> lines,
        BigDecimal totalPrice,
        boolean valid,
        List<String> validationMessages
) {
}
