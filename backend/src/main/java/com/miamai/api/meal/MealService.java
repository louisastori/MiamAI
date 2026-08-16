package com.miamai.api.meal;

import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;

@Service
public class MealService {

    public MealsResponse currentMeals() {
        // Sélection semaine utilisée par l'écran "Mes repas".
        return new MealsResponse(
                "Ma semaine",
                5,
                new BigDecimal("58.00"),
                true,
                List.of(
                        new MealPlanItem("Lundi", "curry-thai-poulet", "Curry de poulet", 30, List.of("Poulet", "Lait de coco", "Riz"), false),
                        new MealPlanItem("Mardi", "wraps-poulet", "Wraps poulet crudités", 20, List.of("Wraps", "Poulet", "Salade"), false),
                        new MealPlanItem("Mercredi", "boeuf-teriyaki", "Bœuf sauce soja + riz", 25, List.of("Bœuf", "Sauce soja", "Riz"), true),
                        new MealPlanItem("Jeudi", "pates-poulet", "Pâtes poulet crème", 25, List.of("Pâtes", "Poulet", "Crème"), false),
                        new MealPlanItem("Vendredi", "riz-cantonais", "Riz cantonais", 20, List.of("Riz", "Œufs", "Petits pois"), false)
                )
        );
    }
}
