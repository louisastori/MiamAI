package com.miamai.api.basket;

import jakarta.validation.constraints.NotBlank;

public record SelectProductRequest(
        @NotBlank String productRef
) {
}
