package com.miamai.api.basket;

import com.miamai.api.leclerc.CartHandoffLine;
import com.miamai.api.leclerc.CartHandoffResult;
import com.miamai.api.leclerc.LeclercDriveAdapter;
import com.miamai.api.leclerc.ProductOffer;
import com.miamai.api.preference.LeclercDrive;
import com.miamai.api.preference.PreferenceService;
import com.miamai.api.recipe.IngredientRequirement;
import com.miamai.api.recipe.RecipeDetail;
import com.miamai.api.recipe.RecipeService;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class BasketService {

    // Les paniers restent en mémoire pour le MVP. Une base de données remplacera
    // cette map quand les comptes utilisateurs seront introduits.
    private final RecipeService recipeService;
    private final PreferenceService preferenceService;
    private final LeclercDriveAdapter leclercDriveAdapter;
    private final Map<String, Basket> baskets = new LinkedHashMap<>();

    public BasketService(
            RecipeService recipeService,
            PreferenceService preferenceService,
            LeclercDriveAdapter leclercDriveAdapter
    ) {
        this.recipeService = recipeService;
        this.preferenceService = preferenceService;
        this.leclercDriveAdapter = leclercDriveAdapter;
    }

    public Basket buildBasket(String recipeId, Integer servings) {
        RecipeDetail recipe = servings == null
                ? recipeService.getRecipe(recipeId)
                : recipeService.getRecipe(recipeId).withServings(servings);
        return buildBasket(recipe);
    }

    public Basket buildSelectedBasket() {
        return buildBasket(recipeService.selectedRecipe());
    }

    public Basket buildBasket(RecipeDetail recipe) {
        LeclercDrive drive = preferenceService.currentProfile().preferredDrive();

        List<BasketLine> lines = recipe.ingredients().stream()
                .map(ingredient -> matchLine(drive, ingredient, null))
                .toList();
        Basket basket = assembleBasket(UUID.randomUUID().toString(), recipe, drive.id(), lines);
        baskets.put(basket.id(), basket);
        return basket;
    }

    public Basket getBasket(String basketId) {
        Basket basket = baskets.get(basketId);
        if (basket == null) {
            throw new IllegalArgumentException("Panier inconnu : " + basketId);
        }
        return basket;
    }

    public Basket selectProduct(String basketId, String ingredientKey, String productRef) {
        Basket basket = getBasket(basketId);
        List<BasketLine> updatedLines = basket.lines().stream()
                .map(line -> line.ingredientKey().equals(ingredientKey) ? replaceSelectedProduct(line, productRef) : line)
                .toList();
        Basket updated = assembleBasket(basket.id(), basket, updatedLines);
        baskets.put(updated.id(), updated);
        return updated;
    }

    public Basket selectCheapestProducts(String basketId) {
        Basket basket = getBasket(basketId);
        List<BasketLine> updatedLines = basket.lines().stream()
                .map(line -> line.alternatives().stream()
                        .filter(ProductOffer::available)
                        .min(Comparator.comparing(ProductOffer::price))
                        .map(offer -> withSelectedProduct(line, offer))
                        .orElse(line))
                .toList();
        Basket updated = assembleBasket(basket.id(), basket, updatedLines);
        baskets.put(updated.id(), updated);
        return updated;
    }

    public BasketValidationResponse validateBasket(String basketId) {
        Basket basket = getBasket(basketId);
        return new BasketValidationResponse(basket.id(), basket.valid(), basket.validationMessages());
    }

    public CartHandoffResult handoff(String basketId) {
        Basket basket = getBasket(basketId);
        if (!basket.valid()) {
            throw new IllegalArgumentException("Le panier n'est pas valide pour l'envoi vers Leclerc");
        }
        List<CartHandoffLine> lines = basket.lines().stream()
                .map(line -> new CartHandoffLine(line.selectedProduct().productRef(), line.packageCount()))
                .toList();
        return leclercDriveAdapter.handoffCart(preferenceService.currentProfile().preferredDrive(), lines);
    }

    private BasketLine matchLine(LeclercDrive drive, IngredientRequirement ingredient, ProductOffer preferredProduct) {
        // L'IA fournit un besoin ingrédient/quantité. Le choix produit vient
        // toujours de l'adaptateur Leclerc, jamais d'un texte généré.
        List<ProductOffer> alternatives = leclercDriveAdapter.searchProducts(drive, ingredient).stream()
                .sorted(Comparator
                        .comparing(ProductOffer::available).reversed())
                .toList();
        ProductOffer selected = preferredProduct == null
                ? alternatives.stream().filter(ProductOffer::available).findFirst().orElse(alternatives.getFirst())
                : preferredProduct;
        return lineFor(ingredient, selected, alternatives);
    }

    private BasketLine replaceSelectedProduct(BasketLine line, String productRef) {
        ProductOffer selected = line.alternatives().stream()
                .filter(offer -> offer.productRef().equals(productRef))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Le produit " + productRef + " n'est pas une alternative pour " + line.ingredientKey()));
        return withSelectedProduct(line, selected);
    }

    private BasketLine withSelectedProduct(BasketLine line, ProductOffer selected) {
        return lineFor(
                new IngredientRequirement(
                        line.ingredientKey(),
                        line.ingredientName(),
                        line.requiredQuantity(),
                        line.requiredUnit(),
                        true,
                        List.of()
                ),
                selected,
                line.alternatives()
        );
    }

    private BasketLine lineFor(IngredientRequirement ingredient, ProductOffer selected, List<ProductOffer> alternatives) {
        int packageCount = selected.available() ? packageCountFor(ingredient, selected) : 0;
        BigDecimal overage = overageFor(ingredient, selected, packageCount);
        BigDecimal total = selected.price()
                .multiply(BigDecimal.valueOf(packageCount))
                .setScale(2, RoundingMode.HALF_UP);
        return new BasketLine(
                ingredient.key(),
                ingredient.name(),
                ingredient.name(),
                ingredient.quantity(),
                ingredient.unit(),
                selected,
                alternatives,
                packageCount,
                overage,
                total
        );
    }

    private int packageCountFor(IngredientRequirement ingredient, ProductOffer offer) {
        // Si l'unité Drive ne correspond pas exactement à l'unité recette
        // (ex. bouteille), on prend un conditionnement par défaut.
        if (!ingredient.unit().equalsIgnoreCase(offer.unit())) {
            return 1;
        }
        if (offer.packageQuantity().compareTo(BigDecimal.ZERO) <= 0) {
            return 1;
        }
        return ingredient.quantity()
                .divide(offer.packageQuantity(), 0, RoundingMode.CEILING)
                .max(BigDecimal.ONE)
                .intValue();
    }

    private BigDecimal overageFor(IngredientRequirement ingredient, ProductOffer offer, int packageCount) {
        if (!ingredient.unit().equalsIgnoreCase(offer.unit())) {
            return BigDecimal.ZERO.setScale(0, RoundingMode.HALF_UP);
        }
        return offer.packageQuantity()
                .multiply(BigDecimal.valueOf(packageCount))
                .subtract(ingredient.quantity())
                .max(BigDecimal.ZERO)
                .setScale(0, RoundingMode.HALF_UP);
    }

    private Basket assembleBasket(String basketId, RecipeDetail recipe, String driveId, List<BasketLine> lines) {
        BigDecimal total = lines.stream()
                .map(BasketLine::lineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(2, RoundingMode.HALF_UP);
        List<String> validationMessages = validationMessages(lines);
        return new Basket(
                basketId,
                recipe.id(),
                recipe.title(),
                recipe.imageUrl(),
                driveId,
                lines,
                total,
                validationMessages.isEmpty(),
                validationMessages
        );
    }

    private Basket assembleBasket(String basketId, Basket previous, List<BasketLine> lines) {
        BigDecimal total = lines.stream()
                .map(BasketLine::lineTotal)
                .reduce(BigDecimal.ZERO, BigDecimal::add)
                .setScale(2, RoundingMode.HALF_UP);
        List<String> validationMessages = validationMessages(lines);
        return new Basket(
                basketId,
                previous.recipeId(),
                previous.recipeTitle(),
                previous.heroImageUrl(),
                previous.driveId(),
                lines,
                total,
                validationMessages.isEmpty(),
                validationMessages
        );
    }

    private List<String> validationMessages(List<BasketLine> lines) {
        return lines.stream()
                .filter(line -> line.selectedProduct() == null || !line.selectedProduct().available())
                .map(line -> "Aucun produit disponible pour " + line.ingredientName())
                .toList();
    }
}
