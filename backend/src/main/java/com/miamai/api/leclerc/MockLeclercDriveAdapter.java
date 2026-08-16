package com.miamai.api.leclerc;

import com.miamai.api.preference.LeclercDrive;
import com.miamai.api.recipe.IngredientRequirement;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Component
public class MockLeclercDriveAdapter implements LeclercDriveAdapter {

    private static final String IMAGE_BASE = "https://images.unsplash.com/";

    @Override
    public List<ProductOffer> searchProducts(LeclercDrive drive, IngredientRequirement ingredient) {
        // Catalogue de démonstration : il reproduit le contrat d'un vrai Drive
        // avec références, formats, prix et disponibilités.
        String normalized = normalize(ingredient.key() + " " + ingredient.name());
        List<ProductOffer> offers = catalog(drive.id()).entrySet().stream()
                .filter(entry -> normalized.contains(entry.getKey()) || entry.getKey().contains(normalized))
                .flatMap(entry -> entry.getValue().stream())
                .toList();

        if (!offers.isEmpty()) {
            return offers;
        }

        return fallbackCatalog(drive.id(), ingredient);
    }

    @Override
    public boolean supportsCartHandoff() {
        return false;
    }

    @Override
    public CartHandoffResult handoffCart(LeclercDrive drive, List<CartHandoffLine> lines) {
        return new CartHandoffResult(
                true,
                "drive-ready",
                "Panier Leclerc préparé. Vous pouvez vérifier les produits avant validation.",
                lines
        );
    }

    private Map<String, List<ProductOffer>> catalog(String driveId) {
        return Map.ofEntries(
                Map.entry("poulet", List.of(
                        offer("LEC-POU-650", "Filets de poulet 650g", "photo-1587593810167-a84920ea0781", "650g", "650", "g", "6.49", true, driveId),
                        offer("LEC-POU-1000", "Aiguillettes de poulet 1kg", "photo-1604503468506-a8da13d82791", "1kg", "1000", "g", "9.35", true, driveId),
                        offer("LEC-DIN-600", "Escalopes de dinde 600g", "photo-1602470520998-f4a52199a3d6", "600g", "600", "g", "5.89", true, driveId)
                )),
                Map.entry("dinde", List.of(
                        offer("LEC-DIN-600", "Escalopes de dinde 600g", "photo-1602470520998-f4a52199a3d6", "600g", "600", "g", "5.89", true, driveId)
                )),
                Map.entry("riz", List.of(
                        offer("LEC-RIZ-BAS-1K", "Riz basmati 1kg", "photo-1536304993881-ff6e9eefa2a6", "1kg", "1000", "g", "2.29", true, driveId),
                        offer("LEC-RIZ-ECO-1K", "Riz long grain 1kg", "photo-1586201375761-83865001e31c", "1kg", "1000", "g", "1.75", true, driveId)
                )),
                Map.entry("sauce-yakitori", List.of(
                        offer("LEC-SAU-YAK-150", "Sauce Yakitori 150ml", "photo-1472476443507-c7a5948772fc", "150ml", "1", "bouteille", "2.15", true, driveId),
                        offer("LEC-SAU-SOJ-150", "Sauce soja salée 150ml", "photo-1512034400317-de97d7d6c3ed", "150ml", "1", "bouteille", "1.79", true, driveId)
                )),
                Map.entry("oignons-nouveaux", List.of(
                        offer("LEC-OIG-NOUV", "Oignons nouveaux botte", "photo-1518977676601-b53f82aba655", "1 botte", "1", "botte", "1.49", true, driveId)
                )),
                Map.entry("graines-sesame", List.of(
                        offer("LEC-SES-90", "Graines de sésame 90g", "photo-1509358271058-acd22cc93898", "90g", "90", "g", "1.39", true, driveId)
                )),
                Map.entry("lait-coco", List.of(
                        offer("LEC-COCO-400", "Lait de coco 400ml", "photo-1518933165971-611dbc9c412d", "400ml", "1", "brique", "1.95", true, driveId)
                )),
                Map.entry("poivrons", List.of(
                        offer("LEC-POIV-3", "Poivrons tricolores x3", "photo-1563565375-f3fdfdbefa83", "3 pièces", "3", "pièces", "2.99", true, driveId)
                )),
                Map.entry("boeuf", List.of(
                        offer("LEC-BOE-500", "Émincés de bœuf 500g", "photo-1603048297172-c92544798d5a", "500g", "500", "g", "7.95", true, driveId)
                )),
                Map.entry("nouilles-soba", List.of(
                        offer("LEC-SOBA-300", "Nouilles soba 300g", "photo-1612927601601-6638404737ce", "300g", "300", "g", "2.65", true, driveId)
                )),
                Map.entry("brocolis", List.of(
                        offer("LEC-BRO-500", "Brocolis 500g", "photo-1459411621453-7b03977f4bfc", "500g", "500", "g", "2.45", true, driveId)
                )),
                Map.entry("sauce-teriyaki", List.of(
                        offer("LEC-TER-150", "Sauce teriyaki 150ml", "photo-1472476443507-c7a5948772fc", "150ml", "1", "bouteille", "2.35", true, driveId)
                ))
        );
    }

    private List<ProductOffer> fallbackCatalog(String driveId, IngredientRequirement ingredient) {
        return List.of(
                new ProductOffer(
                        "MOCK-" + normalize(ingredient.key()).toUpperCase(Locale.ROOT),
                        ingredient.name() + " - produit de démonstration",
                        IMAGE_BASE + "photo-1542838132-92c53300491e",
                        ingredient.quantity().stripTrailingZeros().toPlainString() + ingredient.unit(),
                        ingredient.quantity(),
                        ingredient.unit(),
                        new BigDecimal("1.99"),
                        false,
                        driveId
                )
        );
    }

    private ProductOffer offer(
            String productRef,
            String title,
            String imageId,
            String packageSize,
            String packageQuantity,
            String unit,
            String price,
            boolean available,
            String driveId
    ) {
        return new ProductOffer(
                productRef,
                title,
                IMAGE_BASE + imageId,
                packageSize,
                new BigDecimal(packageQuantity),
                unit,
                new BigDecimal(price),
                available,
                driveId
        );
    }

    private String normalize(String value) {
        return value.toLowerCase(Locale.ROOT)
                .replace(" ", "-")
                .replace("'", "")
                .replace("_", "-");
    }
}
