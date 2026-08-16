package com.miamai.api.meal;

import java.math.BigDecimal;
import java.util.List;

public record MealsResponse(
        String title,
        int mealCount,
        BigDecimal estimatedTotal,
        boolean weeklyPlanningEnabled,
        List<MealPlanItem> meals
) {
}
