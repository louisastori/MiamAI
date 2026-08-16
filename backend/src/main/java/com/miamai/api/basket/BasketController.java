package com.miamai.api.basket;

import com.miamai.api.leclerc.CartHandoffResult;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/baskets")
public class BasketController {

    private final BasketService basketService;

    public BasketController(BasketService basketService) {
        this.basketService = basketService;
    }

    @PostMapping("/build")
    Basket buildBasket(@Valid @RequestBody BuildBasketRequest request) {
        return basketService.buildBasket(request.recipeId(), request.servings());
    }

    @PostMapping("/build-selected")
    Basket buildSelectedBasket() {
        return basketService.buildSelectedBasket();
    }

    @GetMapping("/{basketId}")
    Basket getBasket(@PathVariable String basketId) {
        return basketService.getBasket(basketId);
    }

    @PostMapping("/{basketId}/lines/{ingredientKey}/select")
    Basket selectProduct(
            @PathVariable String basketId,
            @PathVariable String ingredientKey,
            @Valid @RequestBody SelectProductRequest request
    ) {
        return basketService.selectProduct(basketId, ingredientKey, request.productRef());
    }

    @PostMapping("/{basketId}/cheapest")
    Basket selectCheapestProducts(@PathVariable String basketId) {
        return basketService.selectCheapestProducts(basketId);
    }

    @PostMapping("/{basketId}/validate")
    BasketValidationResponse validateBasket(@PathVariable String basketId) {
        return basketService.validateBasket(basketId);
    }

    @PostMapping("/{basketId}/handoff")
    CartHandoffResult handoff(@PathVariable String basketId) {
        return basketService.handoff(basketId);
    }
}
