package com.miamai.api.basket;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public record BuildBasketRequest(
        @NotBlank String recipeId,
        @Min(1) Integer servings
) {
}
