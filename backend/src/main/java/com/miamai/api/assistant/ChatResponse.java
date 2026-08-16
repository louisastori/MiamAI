package com.miamai.api.assistant;

import com.miamai.api.basket.Basket;
import com.miamai.api.recipe.RecipeDetail;
import com.miamai.api.recipe.RecipeProposal;

import java.util.List;

public record ChatResponse(
        String sessionId,
        String assistantMessage,
        List<RecipeProposal> proposals,
        RecipeDetail selectedRecipe,
        Basket basket
) {
}
