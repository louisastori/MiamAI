package com.miamai.api.basket;

import java.util.List;

public record BasketValidationResponse(
        String basketId,
        boolean valid,
        List<String> messages
) {
}
