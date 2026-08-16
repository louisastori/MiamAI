import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models.dart';

class MiamAiApiClient {
  MiamAiApiClient(this.baseUrl, {http.Client? client})
      : _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  // Client HTTP fin : la logique métier reste côté backend.
  Future<PreferenceProfile> getPreferences() async {
    final json = await _get('/preferences');
    return PreferenceProfile.fromJson(json);
  }

  Future<PreferenceProfile> updatePreferences(PreferenceProfile profile) async {
    final json = await _put('/preferences', profile.toJson());
    return PreferenceProfile.fromJson(json);
  }

  Future<ChatResponse> chat(
      {required String message, String? sessionId}) async {
    final json = await _post('/assistant/chat', {
      'sessionId': sessionId,
      'message': message,
    });
    return ChatResponse.fromJson(json);
  }

  Future<RecipeDetail> selectRecipe(String recipeId, {int? servings}) async {
    final json = await _post('/recipes/select', {
      'recipeId': recipeId,
      'servings': servings,
    });
    return RecipeDetail.fromJson(json);
  }

  Future<RecipeDetail> updateSelectedRecipe({
    int? servings,
    List<String>? removeIngredients,
    Map<String, String>? replacements,
  }) async {
    final json = await _patch('/recipes/selected', {
      'servings': servings,
      'removeIngredients': removeIngredients ?? const [],
      'replacements': replacements ?? const {},
    });
    return RecipeDetail.fromJson(json);
  }

  Future<Basket> buildBasket(String recipeId, {int? servings}) async {
    final json = await _post('/baskets/build', {
      'recipeId': recipeId,
      'servings': servings,
    });
    return Basket.fromJson(json);
  }

  Future<Basket> buildSelectedBasket() async {
    final json = await _post('/baskets/build-selected', const {});
    return Basket.fromJson(json);
  }

  Future<Basket> selectBasketProduct({
    required String basketId,
    required String ingredientKey,
    required String productRef,
  }) async {
    final json = await _post('/baskets/$basketId/lines/$ingredientKey/select', {
      'productRef': productRef,
    });
    return Basket.fromJson(json);
  }

  Future<Basket> selectCheapestProducts(String basketId) async {
    final json = await _post('/baskets/$basketId/cheapest', const {});
    return Basket.fromJson(json);
  }

  Future<Map<String, dynamic>> handoffBasket(String basketId) async {
    return _post('/baskets/$basketId/handoff', const {});
  }

  Future<MealsResponse> getMeals() async {
    final json = await _get('/meals');
    return MealsResponse.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _client.get(_uri(path));
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      _uri(path),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _put(
      String path, Map<String, dynamic> body) async {
    final response = await _client.put(
      _uri(path),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _patch(
      String path, Map<String, dynamic> body) async {
    final response = await _client.patch(
      _uri(path),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Uri _uri(String path) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse('$normalizedBase$path');
  }

  Map<String, dynamic> _decode(http.Response response) {
    // Le backend renvoie les erreurs au format ApiError avec un champ `message`.
    final body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw MiamAiApiException(
      statusCode: response.statusCode,
      message: body['message'] as String? ?? 'Erreur API MiamAI',
    );
  }
}

class MiamAiApiException implements Exception {
  const MiamAiApiException({required this.statusCode, required this.message});

  final int statusCode;
  final String message;

  @override
  String toString() => 'MiamAiApiException($statusCode): $message';
}
