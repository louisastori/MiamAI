package com.miamai.api.basket;

import com.miamai.api.leclerc.ProductOffer;

import java.math.BigDecimal;
import java.util.List;

public record BasketLine(
        String ingredientKey,
        String ingredientName,
        String displayCategory,
        BigDecimal requiredQuantity,
        String requiredUnit,
        ProductOffer selectedProduct,
        List<ProductOffer> alternatives,
        int packageCount,
        BigDecimal overageQuantity,
        BigDecimal lineTotal
) {
}
