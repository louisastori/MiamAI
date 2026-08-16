import 'package:flutter/widgets.dart';

import 'api/miamai_api_client.dart';
import 'models.dart';

class MiamAiAppState extends ChangeNotifier {
  MiamAiAppState(this.apiClient);

  final MiamAiApiClient apiClient;

  // État applicatif volontairement centralisé pour le MVP.
  // Cela évite d'introduire un gestionnaire d'état plus lourd trop tôt.
  bool isBusy = false;
  String? errorMessage;
  String? sessionId;
  String lastAssistantMessage =
      'Je vous propose ces 3 recettes faciles à réaliser :';
  List<RecipeProposal> proposals = const [];
  RecipeDetail? selectedRecipe;
  Basket? basket;
  PreferenceProfile? preferences;
  MealsResponse? meals;

  Future<void> loadInitialData() async {
    await _run(() async {
      final loadedPreferences = await apiClient.getPreferences();
      final loadedMeals = await apiClient.getMeals();
      preferences = loadedPreferences;
      meals = loadedMeals;
    });
  }

  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) {
      return;
    }
    await _run(() async {
      final response =
          await apiClient.chat(message: message.trim(), sessionId: sessionId);
      sessionId = response.sessionId;
      lastAssistantMessage = response.assistantMessage;
      if (response.proposals.isNotEmpty) {
        proposals = response.proposals;
      }
      if (response.selectedRecipe != null) {
        selectedRecipe = response.selectedRecipe;
      }
      if (response.basket != null) {
        basket = response.basket;
      }
    });
  }

  Future<RecipeDetail?> selectRecipe(RecipeProposal proposal) async {
    RecipeDetail? result;
    await _run(() async {
      final servings = preferences?.peopleCount ?? proposal.servings;
      result = await apiClient.selectRecipe(proposal.id, servings: servings);
      selectedRecipe = result;
    });
    return result;
  }

  Future<void> prepareBasket() async {
    final recipe = selectedRecipe;
    if (recipe == null) {
      return;
    }
    await _run(() async {
      basket =
          await apiClient.buildBasket(recipe.id, servings: recipe.servings);
    });
  }

  Future<void> chooseAlternative(BasketLine line, ProductOffer offer) async {
    final currentBasket = basket;
    if (currentBasket == null) {
      return;
    }
    await _run(() async {
      basket = await apiClient.selectBasketProduct(
        basketId: currentBasket.id,
        ingredientKey: line.ingredientKey,
        productRef: offer.productRef,
      );
    });
  }

  Future<void> selectCheapestBasket() async {
    final currentBasket = basket;
    if (currentBasket == null) {
      return;
    }
    await _run(() async {
      basket = await apiClient.selectCheapestProducts(currentBasket.id);
    });
  }

  Future<String> handoffBasket() async {
    final currentBasket = basket;
    if (currentBasket == null) {
      return 'Aucun panier à envoyer.';
    }
    String message = '';
    await _run(() async {
      final response = await apiClient.handoffBasket(currentBasket.id);
      message = response['message'] as String? ?? 'Panier préparé.';
    });
    return message;
  }

  Future<void> updatePreferences(PreferenceProfile nextProfile) async {
    await _run(() async {
      preferences = await apiClient.updatePreferences(nextProfile);
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
    } on MiamAiApiException catch (error) {
      errorMessage = error.message;
    } catch (error) {
      errorMessage = 'Impossible de joindre MiamAI pour le moment.';
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}

class MiamAiStateScope extends InheritedNotifier<MiamAiAppState> {
  const MiamAiStateScope({
    required MiamAiAppState state,
    required super.child,
    super.key,
  }) : super(notifier: state);

  static MiamAiAppState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<MiamAiStateScope>();
    assert(scope != null, 'MiamAiStateScope is missing');
    return scope!.notifier!;
  }
}
