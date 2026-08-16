package com.miamai.api.recipe;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/recipes")
public class RecipeController {

    private final RecipeService recipeService;

    public RecipeController(RecipeService recipeService) {
        this.recipeService = recipeService;
    }

    @PostMapping("/select")
    RecipeDetail selectRecipe(@Valid @RequestBody SelectRecipeRequest request) {
        return recipeService.selectRecipe(request.recipeId(), request.servings());
    }

    @GetMapping("/{recipeId}")
    RecipeDetail getRecipe(@PathVariable String recipeId) {
        return recipeService.getRecipe(recipeId);
    }

    @PatchMapping("/selected")
    RecipeDetail updateSelectedRecipe(@Valid @RequestBody UpdateRecipeRequest request) {
        return recipeService.updateSelectedRecipe(request);
    }
}
