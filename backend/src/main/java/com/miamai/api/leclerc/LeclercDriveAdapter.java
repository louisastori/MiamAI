package com.miamai.api.leclerc;

import com.miamai.api.preference.LeclercDrive;
import com.miamai.api.recipe.IngredientRequirement;

import java.util.List;

public interface LeclercDriveAdapter {

    List<ProductOffer> searchProducts(LeclercDrive drive, IngredientRequirement ingredient);

    boolean supportsCartHandoff();

    CartHandoffResult handoffCart(LeclercDrive drive, List<CartHandoffLine> lines);
}
