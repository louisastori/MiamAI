import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:miamai/api/miamai_api_client.dart';
import 'package:miamai/main.dart';
import 'package:miamai/models.dart';

void main() {
  testWidgets('affiche le shell principal de MiamAI', (tester) async {
    await tester.pumpWidget(MiamAiApp(apiClient: _FakeMiamAiApiClient()));
    await tester.pumpAndSettle();

    expect(find.text('Assistant cuisine'), findsOneWidget);
    expect(find.text('Pose ta question...'), findsOneWidget);
    expect(find.text('Mes repas'), findsOneWidget);
  });

  testWidgets('affiche les cartes recettes sans overflow avec texte agrandi',
      (tester) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(MiamAiApp(apiClient: _FakeMiamAiApiClient()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.enterText(find.byType(TextField), 'Je veux un repas rapide');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    expect(find.text('Poulet yakitori'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Choisir').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choisir').first);
    await tester.pumpAndSettle();

    expect(find.text('Panier pour Poulet yakitori'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('affiche les repas semaine sans overflow avec texte agrandi',
      (tester) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(1080, 2400);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });

    await tester.pumpWidget(MiamAiApp(apiClient: _FakeMiamAiApiClient()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mes repas'));
    await tester.pumpAndSettle();

    expect(find.text('Ma semaine'), findsOneWidget);
    expect(find.text('Pâtes poulet crème'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Créer le panier'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Créer le panier'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Panier semaine préparé'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FakeMiamAiApiClient extends MiamAiApiClient {
  _FakeMiamAiApiClient() : super('http://localhost');

  @override
  Future<PreferenceProfile> getPreferences() async {
    return const PreferenceProfile(
      preferredDrive: LeclercDrive(
        id: 'leclerc-pessac',
        name: 'Pessac',
        address: 'Avenue Gutenberg, 33600 Pessac',
      ),
      peopleCount: 3,
      weeklyBudget: 60,
      defaultDietMode: 'Équilibré',
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
      mealCount: 2,
      estimatedTotal: 24.5,
      weeklyPlanningEnabled: true,
      meals: <MealPlanItem>[
        MealPlanItem(
          day: 'Jeudi',
          recipeId: 'pates-poulet',
          title: 'Pâtes poulet crème',
          prepTimeMinutes: 25,
          ingredientTags: <String>['Pâtes', 'Poulet', 'Crème'],
          selected: false,
        ),
        MealPlanItem(
          day: 'Vendredi',
          recipeId: 'riz-cantonais',
          title: 'Riz cantonais',
          prepTimeMinutes: 20,
          ingredientTags: <String>['Riz', 'Œufs', 'Petits pois'],
          selected: false,
        ),
      ],
    );
  }

  @override
  Future<ChatResponse> chat(
      {required String message, String? sessionId}) async {
    return const ChatResponse(
      sessionId: 'test-session',
      assistantMessage: 'Je vous propose ces 3 recettes faciles à réaliser :',
      proposals: <RecipeProposal>[
        RecipeProposal(
          id: 'poulet-yakitori',
          title: 'Poulet yakitori',
          description: 'Brochettes de poulet, riz basmati et légumes.',
          cuisine: 'Asiatique',
          servings: 3,
          prepTimeMinutes: 30,
          estimatedCost: 11.8,
          imageUrl: 'https://example.com/yakitori.jpg',
          nutriScore: 'A',
          tags: <String>['Rapide'],
        ),
        RecipeProposal(
          id: 'curry-thai-poulet',
          title: 'Curry de poulet',
          description: 'Curry au lait de coco.',
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
    return RecipeDetail(
      id: recipeId,
      title: 'Poulet yakitori',
      description: 'Brochettes de poulet, riz basmati et légumes.',
      cuisine: 'Asiatique',
      baseServings: 3,
      servings: servings ?? 3,
      prepTimeMinutes: 30,
      estimatedBasketCost: 13.81,
      imageUrl: 'https://example.com/yakitori.jpg',
      nutriScore: 'A',
      nutrition: null,
      ingredients: const <IngredientRequirement>[
        IngredientRequirement(
          key: 'poulet',
          name: 'Poulet',
          quantity: 600,
          unit: 'g',
          scalable: true,
          replacementHints: <String>['Dinde'],
        ),
      ],
      steps: const <RecipeStep>[],
      chefTips: const <String>[],
      tags: const <String>['Rapide'],
    );
  }

  @override
  Future<Basket> buildBasket(String recipeId, {int? servings}) async {
    const product = ProductOffer(
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
    return const Basket(
      id: 'basket-test',
      recipeId: 'poulet-yakitori',
      recipeTitle: 'Poulet yakitori',
      heroImageUrl: 'https://example.com/yakitori.jpg',
      driveId: 'leclerc-pessac',
      lines: <BasketLine>[
        BasketLine(
          ingredientKey: 'poulet',
          ingredientName: 'Poulet',
          displayCategory: 'Poulet',
          requiredQuantity: 600,
          requiredUnit: 'g',
          selectedProduct: product,
          alternatives: <ProductOffer>[product],
          packageCount: 1,
          overageQuantity: 50,
          lineTotal: 6.49,
        ),
      ],
      totalPrice: 13.81,
      valid: true,
      validationMessages: <String>[],
    );
  }
}
