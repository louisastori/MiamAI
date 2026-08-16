import 'package:flutter_test/flutter_test.dart';
import 'package:miamai/api/miamai_api_client.dart';
import 'package:miamai/app_state.dart';
import 'package:miamai/models.dart';

void main() {
  test('gere le parcours recette panier alternative et budget', () async {
    final apiClient = _FlowFakeMiamAiApiClient();
    final state = MiamAiAppState(apiClient);

    await state.loadInitialData();
    await state.sendMessage(
        'Je veux un repas asiatique pour 3 personnes a moins de 15 euros');

    expect(state.preferences?.weeklyBudget, 15);
    expect(state.proposals, isNotEmpty);
    expect(
        state.proposals.every((recipe) => recipe.estimatedCost <= 15), isTrue);

    final selected = await state.selectRecipe(state.proposals.first);
    expect(selected?.servings, 3);
    expect(state.selectedRecipe?.title, 'Poulet yakitori');

    await state.prepareBasket();
    expect(state.basket?.totalPrice, 13.81);

    final riceLine = state.basket!.lines.firstWhere(
      (line) => line.ingredientKey == 'riz',
    );
    final cheaperRice = riceLine.alternatives.firstWhere(
      (offer) => offer.productRef == 'LEC-RIZ-ECO-1K',
    );

    await state.chooseAlternative(riceLine, cheaperRice);

    final updatedRiceLine = state.basket!.lines.firstWhere(
      (line) => line.ingredientKey == 'riz',
    );
    expect(updatedRiceLine.selectedProduct.productRef, 'LEC-RIZ-ECO-1K');
    expect(state.basket?.totalPrice, lessThan(13.81));
  });

  test('applique les commandes chat sur la recette selectionnee', () async {
    final state = MiamAiAppState(_FlowFakeMiamAiApiClient());

    await state.loadInitialData();
    await state.sendMessage('Je veux manger asiatique pour 3 personnes');
    await state.selectRecipe(state.proposals.first);
    await state.prepareBasket();

    await state.sendMessage('On sera finalement 4 personnes');
    expect(state.selectedRecipe?.servings, 4);
    expect(state.basket?.totalPrice, 20.30);

    await state.sendMessage('Remplace le poulet par de la dinde');
    expect(
      state.selectedRecipe?.ingredients.map((ingredient) => ingredient.name),
      contains('Dinde'),
    );
    expect(
      state.basket?.lines.map((line) => line.selectedProduct.title),
      contains('Escalopes de dinde 600g'),
    );
  });
}

class _FlowFakeMiamAiApiClient extends MiamAiApiClient {
  _FlowFakeMiamAiApiClient() : super('http://localhost');

  @override
  Future<PreferenceProfile> getPreferences() async {
    return const PreferenceProfile(
      preferredDrive: LeclercDrive(
        id: 'leclerc-pessac',
        name: 'Pessac',
        address: 'Avenue Gutenberg, 33600 Pessac',
      ),
      peopleCount: 3,
      weeklyBudget: 15,
      defaultDietMode: 'Equilibre',
      dietaryRestrictions: <String>{},
      excludedIngredients: <String>[],
      kitchenEquipment: <String>{},
      planningReminders: true,
      leclercPromotions: false,
    );
  }

  @override
  Future<MealsResponse> getMeals() async {
    return const MealsResponse(
      title: 'Ma semaine',
      mealCount: 0,
      estimatedTotal: 0,
      weeklyPlanningEnabled: true,
      meals: <MealPlanItem>[],
    );
  }

  @override
  Future<ChatResponse> chat({
    required String message,
    String? sessionId,
  }) async {
    final normalized = message.toLowerCase();
    if (normalized.contains('finalement 4')) {
      return ChatResponse(
        sessionId: sessionId ?? 'test-session',
        assistantMessage: "C'est recalcule pour 4 personnes.",
        proposals: const <RecipeProposal>[],
        selectedRecipe: _recipe(servings: 4),
        basket: _basket(totalPrice: 20.30, servings: 4),
      );
    }
    if (normalized.contains('dinde')) {
      return ChatResponse(
        sessionId: sessionId ?? 'test-session',
        assistantMessage: "J'ai applique le remplacement.",
        proposals: const <RecipeProposal>[],
        selectedRecipe: _recipe(useTurkey: true),
        basket: _basket(totalPrice: 13.21, useTurkey: true),
      );
    }
    return ChatResponse(
      sessionId: sessionId ?? 'test-session',
      assistantMessage: 'Je vous propose ces recettes.',
      proposals: const <RecipeProposal>[
        RecipeProposal(
          id: 'poulet-yakitori',
          title: 'Poulet yakitori',
          description: 'Brochettes de poulet et riz.',
          cuisine: 'Asiatique',
          servings: 3,
          prepTimeMinutes: 30,
          estimatedCost: 11.80,
          imageUrl: 'https://example.com/yakitori.jpg',
          nutriScore: 'A',
          tags: <String>['Petit budget'],
        ),
        RecipeProposal(
          id: 'curry-thai-poulet',
          title: 'Curry thai poulet',
          description: 'Curry coco et riz.',
          cuisine: 'Asiatique',
          servings: 3,
          prepTimeMinutes: 35,
          estimatedCost: 15,
          imageUrl: 'https://example.com/curry.jpg',
          nutriScore: 'B',
          tags: <String>['Asiatique'],
        ),
      ],
    );
  }

  @override
  Future<RecipeDetail> selectRecipe(String recipeId, {int? servings}) async {
    return _recipe(servings: servings ?? 3);
  }

  @override
  Future<Basket> buildBasket(String recipeId, {int? servings}) async {
    return _basket(servings: servings ?? 3);
  }

  @override
  Future<Basket> selectBasketProduct({
    required String basketId,
    required String ingredientKey,
    required String productRef,
  }) async {
    return _basket(riceProductRef: productRef, totalPrice: 13.27);
  }
}

RecipeDetail _recipe({int servings = 3, bool useTurkey = false}) {
  final proteinName = useTurkey ? 'Dinde' : 'Poulet';
  final proteinKey = useTurkey ? 'dinde' : 'poulet';
  return RecipeDetail(
    id: 'poulet-yakitori',
    title: 'Poulet yakitori',
    description: 'Brochettes et riz.',
    cuisine: 'Asiatique',
    baseServings: 3,
    servings: servings,
    prepTimeMinutes: 30,
    estimatedBasketCost: servings == 4 ? 15.73 : 13.81,
    imageUrl: 'https://example.com/yakitori.jpg',
    nutriScore: 'A',
    nutrition: null,
    ingredients: <IngredientRequirement>[
      IngredientRequirement(
        key: proteinKey,
        name: proteinName,
        quantity: servings == 4 ? 800 : 600,
        unit: 'g',
        scalable: true,
        replacementHints: const <String>['Dinde'],
      ),
      const IngredientRequirement(
        key: 'riz',
        name: 'Riz',
        quantity: 300,
        unit: 'g',
        scalable: true,
        replacementHints: <String>[],
      ),
    ],
    steps: const <RecipeStep>[],
    chefTips: const <String>[],
    tags: const <String>['Petit budget'],
  );
}

Basket _basket({
  String riceProductRef = 'LEC-RIZ-BAS-1K',
  double totalPrice = 13.81,
  int servings = 3,
  bool useTurkey = false,
}) {
  final riceProduct =
      riceProductRef == 'LEC-RIZ-ECO-1K' ? _riceEco : _riceBasmati;
  final proteinProduct = useTurkey ? _turkey : _chicken;
  return Basket(
    id: 'basket-test',
    recipeId: 'poulet-yakitori',
    recipeTitle: 'Poulet yakitori',
    heroImageUrl: 'https://example.com/yakitori.jpg',
    driveId: 'leclerc-pessac',
    totalPrice: totalPrice,
    valid: true,
    validationMessages: const <String>[],
    lines: <BasketLine>[
      BasketLine(
        ingredientKey: useTurkey ? 'dinde' : 'poulet',
        ingredientName: useTurkey ? 'Dinde' : 'Poulet',
        displayCategory: useTurkey ? 'Dinde' : 'Poulet',
        requiredQuantity: servings == 4 ? 800 : 600,
        requiredUnit: 'g',
        selectedProduct: proteinProduct,
        alternatives: const <ProductOffer>[_chicken, _turkey],
        packageCount: servings == 4 && !useTurkey ? 2 : 1,
        overageQuantity: 50,
        lineTotal: useTurkey ? 5.89 : 6.49,
      ),
      BasketLine(
        ingredientKey: 'riz',
        ingredientName: 'Riz',
        displayCategory: 'Riz',
        requiredQuantity: servings == 4 ? 400 : 300,
        requiredUnit: 'g',
        selectedProduct: riceProduct,
        alternatives: const <ProductOffer>[_riceBasmati, _riceEco],
        packageCount: 1,
        overageQuantity: servings == 4 ? 600 : 700,
        lineTotal: riceProduct.price,
      ),
    ],
  );
}

const _chicken = ProductOffer(
  productRef: 'LEC-POU-650',
  title: 'Filets de poulet 650g',
  imageUrl: 'https://example.com/poulet.jpg',
  packageSize: '650g',
  packageQuantity: 650,
  unit: 'g',
  price: 6.49,
  available: true,
  sourceDriveId: 'leclerc-pessac',
);

const _turkey = ProductOffer(
  productRef: 'LEC-DIN-600',
  title: 'Escalopes de dinde 600g',
  imageUrl: 'https://example.com/dinde.jpg',
  packageSize: '600g',
  packageQuantity: 600,
  unit: 'g',
  price: 5.89,
  available: true,
  sourceDriveId: 'leclerc-pessac',
);

const _riceBasmati = ProductOffer(
  productRef: 'LEC-RIZ-BAS-1K',
  title: 'Riz basmati 1kg',
  imageUrl: 'https://example.com/riz.jpg',
  packageSize: '1kg',
  packageQuantity: 1000,
  unit: 'g',
  price: 2.29,
  available: true,
  sourceDriveId: 'leclerc-pessac',
);

const _riceEco = ProductOffer(
  productRef: 'LEC-RIZ-ECO-1K',
  title: 'Riz long grain 1kg',
  imageUrl: 'https://example.com/riz-eco.jpg',
  packageSize: '1kg',
  packageQuantity: 1000,
  unit: 'g',
  price: 1.75,
  available: true,
  sourceDriveId: 'leclerc-pessac',
);
