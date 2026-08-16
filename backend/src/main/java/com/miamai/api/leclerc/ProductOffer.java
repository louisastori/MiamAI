package com.miamai.api.leclerc;

import java.math.BigDecimal;

public record ProductOffer(
        String productRef,
        String title,
        String imageUrl,
        String packageSize,
        BigDecimal packageQuantity,
        String unit,
        BigDecimal price,
        boolean available,
        String sourceDriveId
) {
}
