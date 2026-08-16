// Les noms de champs restent alignés sur le contrat JSON de l'API.
// Les libellés visibles sont traduits dans les écrans.
class LeclercDrive {
  const LeclercDrive({
    required this.id,
    required this.name,
    required this.address,
  });

  final String id;
  final String name;
  final String address;

  factory LeclercDrive.fromJson(Map<String, dynamic> json) {
    return LeclercDrive(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
      };
}

class PreferenceProfile {
  const PreferenceProfile({
    required this.preferredDrive,
    required this.peopleCount,
    required this.weeklyBudget,
    required this.defaultDietMode,
    required this.dietaryRestrictions,
    required this.excludedIngredients,
    required this.kitchenEquipment,
    required this.planningReminders,
    required this.leclercPromotions,
  });

  final LeclercDrive preferredDrive;
  final int peopleCount;
  final double weeklyBudget;
  final String defaultDietMode;
  final Set<String> dietaryRestrictions;
  final List<String> excludedIngredients;
  final Set<String> kitchenEquipment;
  final bool planningReminders;
  final bool leclercPromotions;

  factory PreferenceProfile.fromJson(Map<String, dynamic> json) {
    return PreferenceProfile(
      preferredDrive:
          LeclercDrive.fromJson(json['preferredDrive'] as Map<String, dynamic>),
      peopleCount: json['peopleCount'] as int,
      weeklyBudget: _doubleValue(json['weeklyBudget']),
      defaultDietMode: json['defaultDietMode'] as String,
      dietaryRestrictions: _stringSet(json['dietaryRestrictions']),
      excludedIngredients: _stringList(json['excludedIngredients']),
      kitchenEquipment: _stringSet(json['kitchenEquipment']),
      planningReminders: json['planningReminders'] as bool,
      leclercPromotions: json['leclercPromotions'] as bool,
    );
  }

  PreferenceProfile copyWith({
    LeclercDrive? preferredDrive,
    int? peopleCount,
    double? weeklyBudget,
    String? defaultDietMode,
    Set<String>? dietaryRestrictions,
    List<String>? excludedIngredients,
    Set<String>? kitchenEquipment,
    bool? planningReminders,
    bool? leclercPromotions,
  }) {
    return PreferenceProfile(
      preferredDrive: preferredDrive ?? this.preferredDrive,
      peopleCount: peopleCount ?? this.peopleCount,
      weeklyBudget: weeklyBudget ?? this.weeklyBudget,
      defaultDietMode: defaultDietMode ?? this.defaultDietMode,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      excludedIngredients: excludedIngredients ?? this.excludedIngredients,
      kitchenEquipment: kitchenEquipment ?? this.kitchenEquipment,
      planningReminders: planningReminders ?? this.planningReminders,
      leclercPromotions: leclercPromotions ?? this.leclercPromotions,
    );
  }

  Map<String, dynamic> toJson() => {
        'preferredDrive': preferredDrive.toJson(),
        'peopleCount': peopleCount,
        'weeklyBudget': weeklyBudget,
        'defaultDietMode': defaultDietMode,
        'dietaryRestrictions': dietaryRestrictions.toList(),
        'excludedIngredients': excludedIngredients,
        'kitchenEquipment': kitchenEquipment.toList(),
        'planningReminders': planningReminders,
        'leclercPromotions': leclercPromotions,
      };
}

class RecipeProposal {
  const RecipeProposal({
    required this.id,
    required this.title,
    required this.description,
    required this.cuisine,
    required this.servings,
    required this.prepTimeMinutes,
    required this.estimatedCost,
    required this.imageUrl,
    required this.nutriScore,
    required this.tags,
  });

  final String id;
  final String title;
  final String description;
  final String cuisine;
  final int servings;
  final int prepTimeMinutes;
  final double estimatedCost;
  final String imageUrl;
  final String? nutriScore;
  final List<String> tags;

  factory RecipeProposal.fromJson(Map<String, dynamic> json) {
    return RecipeProposal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      cuisine: json['cuisine'] as String,
      servings: json['servings'] as int,
      prepTimeMinutes: json['prepTimeMinutes'] as int,
      estimatedCost: _doubleValue(json['estimatedCost']),
      imageUrl: json['imageUrl'] as String,
      nutriScore: json['nutriScore'] as String?,
      tags: _stringList(json['tags']),
    );
  }
}

class Nutrition {
  const Nutrition({
    required this.caloriesKcal,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  final int caloriesKcal;
  final int proteinGrams;
  final int carbsGrams;
  final int fatGrams;

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      caloriesKcal: json['caloriesKcal'] as int,
      proteinGrams: json['proteinGrams'] as int,
      carbsGrams: json['carbsGrams'] as int,
      fatGrams: json['fatGrams'] as int,
    );
  }
}

class IngredientRequirement {
  const IngredientRequirement({
    required this.key,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.scalable,
    required this.replacementHints,
  });

  final String key;
  final String name;
  final double quantity;
  final String unit;
  final bool scalable;
  final List<String> replacementHints;

  factory IngredientRequirement.fromJson(Map<String, dynamic> json) {
    return IngredientRequirement(
      key: json['key'] as String,
      name: json['name'] as String,
      quantity: _doubleValue(json['quantity']),
      unit: json['unit'] as String,
      scalable: json['scalable'] as bool,
      replacementHints: _stringList(json['replacementHints']),
    );
  }

  String get displayQuantity {
    final value = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return '$value $unit';
  }
}

class RecipeStep {
  const RecipeStep({required this.order, required this.text});

  final int order;
  final String text;

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      order: json['order'] as int,
      text: json['text'] as String,
    );
  }
}

class RecipeDetail {
  const RecipeDetail({
    required this.id,
    required this.title,
    required this.description,
    required this.cuisine,
    required this.baseServings,
    required this.servings,
    required this.prepTimeMinutes,
    required this.estimatedBasketCost,
    required this.imageUrl,
    required this.nutriScore,
    required this.nutrition,
    required this.ingredients,
    required this.steps,
    required this.chefTips,
    required this.tags,
  });

  final String id;
  final String title;
  final String description;
  final String cuisine;
  final int baseServings;
  final int servings;
  final int prepTimeMinutes;
  final double estimatedBasketCost;
  final String imageUrl;
  final String? nutriScore;
  final Nutrition? nutrition;
  final List<IngredientRequirement> ingredients;
  final List<RecipeStep> steps;
  final List<String> chefTips;
  final List<String> tags;

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    return RecipeDetail(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      cuisine: json['cuisine'] as String,
      baseServings: json['baseServings'] as int,
      servings: json['servings'] as int,
      prepTimeMinutes: json['prepTimeMinutes'] as int,
      estimatedBasketCost: _doubleValue(json['estimatedBasketCost']),
      imageUrl: json['imageUrl'] as String,
      nutriScore: json['nutriScore'] as String?,
      nutrition: json['nutrition'] == null
          ? null
          : Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
      ingredients:
          _objectList(json['ingredients'], IngredientRequirement.fromJson),
      steps: _objectList(json['steps'], RecipeStep.fromJson),
      chefTips: _stringList(json['chefTips']),
      tags: _stringList(json['tags']),
    );
  }
}

class ProductOffer {
  const ProductOffer({
    required this.productRef,
    required this.title,
    required this.imageUrl,
    required this.packageSize,
    required this.packageQuantity,
    required this.unit,
    required this.price,
    required this.available,
    required this.sourceDriveId,
  });

  final String productRef;
  final String title;
  final String imageUrl;
  final String packageSize;
  final double packageQuantity;
  final String unit;
  final double price;
  final bool available;
  final String sourceDriveId;

  factory ProductOffer.fromJson(Map<String, dynamic> json) {
    return ProductOffer(
      productRef: json['productRef'] as String,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      packageSize: json['packageSize'] as String,
      packageQuantity: _doubleValue(json['packageQuantity']),
      unit: json['unit'] as String,
      price: _doubleValue(json['price']),
      available: json['available'] as bool,
      sourceDriveId: json['sourceDriveId'] as String,
    );
  }
}

class BasketLine {
  const BasketLine({
    required this.ingredientKey,
    required this.ingredientName,
    required this.displayCategory,
    required this.requiredQuantity,
    required this.requiredUnit,
    required this.selectedProduct,
    required this.alternatives,
    required this.packageCount,
    required this.overageQuantity,
    required this.lineTotal,
  });

  final String ingredientKey;
  final String ingredientName;
  final String displayCategory;
  final double requiredQuantity;
  final String requiredUnit;
  final ProductOffer selectedProduct;
  final List<ProductOffer> alternatives;
  final int packageCount;
  final double overageQuantity;
  final double lineTotal;

  factory BasketLine.fromJson(Map<String, dynamic> json) {
    return BasketLine(
      ingredientKey: json['ingredientKey'] as String,
      ingredientName: json['ingredientName'] as String,
      displayCategory: json['displayCategory'] as String,
      requiredQuantity: _doubleValue(json['requiredQuantity']),
      requiredUnit: json['requiredUnit'] as String,
      selectedProduct: ProductOffer.fromJson(
          json['selectedProduct'] as Map<String, dynamic>),
      alternatives: _objectList(json['alternatives'], ProductOffer.fromJson),
      packageCount: json['packageCount'] as int,
      overageQuantity: _doubleValue(json['overageQuantity']),
      lineTotal: _doubleValue(json['lineTotal']),
    );
  }
}

class Basket {
  const Basket({
    required this.id,
    required this.recipeId,
    required this.recipeTitle,
    required this.heroImageUrl,
    required this.driveId,
    required this.lines,
    required this.totalPrice,
    required this.valid,
    required this.validationMessages,
  });

  final String id;
  final String recipeId;
  final String recipeTitle;
  final String heroImageUrl;
  final String driveId;
  final List<BasketLine> lines;
  final double totalPrice;
  final bool valid;
  final List<String> validationMessages;

  factory Basket.fromJson(Map<String, dynamic> json) {
    return Basket(
      id: json['id'] as String,
      recipeId: json['recipeId'] as String,
      recipeTitle: json['recipeTitle'] as String,
      heroImageUrl: json['heroImageUrl'] as String,
      driveId: json['driveId'] as String,
      lines: _objectList(json['lines'], BasketLine.fromJson),
      totalPrice: _doubleValue(json['totalPrice']),
      valid: json['valid'] as bool,
      validationMessages: _stringList(json['validationMessages']),
    );
  }
}

class ChatResponse {
  const ChatResponse({
    required this.sessionId,
    required this.assistantMessage,
    required this.proposals,
    this.selectedRecipe,
    this.basket,
  });

  final String sessionId;
  final String assistantMessage;
  final List<RecipeProposal> proposals;
  final RecipeDetail? selectedRecipe;
  final Basket? basket;

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      sessionId: json['sessionId'] as String,
      assistantMessage: json['assistantMessage'] as String,
      proposals: _objectList(json['proposals'], RecipeProposal.fromJson),
      selectedRecipe: json['selectedRecipe'] == null
          ? null
          : RecipeDetail.fromJson(
              json['selectedRecipe'] as Map<String, dynamic>),
      basket: json['basket'] == null
          ? null
          : Basket.fromJson(json['basket'] as Map<String, dynamic>),
    );
  }
}

class MealPlanItem {
  const MealPlanItem({
    required this.day,
    required this.recipeId,
    required this.title,
    required this.prepTimeMinutes,
    required this.ingredientTags,
    required this.selected,
  });

  final String day;
  final String recipeId;
  final String title;
  final int prepTimeMinutes;
  final List<String> ingredientTags;
  final bool selected;

  factory MealPlanItem.fromJson(Map<String, dynamic> json) {
    return MealPlanItem(
      day: json['day'] as String,
      recipeId: json['recipeId'] as String,
      title: json['title'] as String,
      prepTimeMinutes: json['prepTimeMinutes'] as int,
      ingredientTags: _stringList(json['ingredientTags']),
      selected: json['selected'] as bool,
    );
  }
}

class MealsResponse {
  const MealsResponse({
    required this.title,
    required this.mealCount,
    required this.estimatedTotal,
    required this.weeklyPlanningEnabled,
    required this.meals,
  });

  final String title;
  final int mealCount;
  final double estimatedTotal;
  final bool weeklyPlanningEnabled;
  final List<MealPlanItem> meals;

  factory MealsResponse.fromJson(Map<String, dynamic> json) {
    return MealsResponse(
      title: json['title'] as String,
      mealCount: json['mealCount'] as int,
      estimatedTotal: _doubleValue(json['estimatedTotal']),
      weeklyPlanningEnabled: json['weeklyPlanningEnabled'] as bool,
      meals: _objectList(json['meals'], MealPlanItem.fromJson),
    );
  }
}

double _doubleValue(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.parse(value as String);
}

List<String> _stringList(dynamic value) {
  if (value == null) {
    return const [];
  }
  return (value as List<dynamic>).map((item) => item as String).toList();
}

Set<String> _stringSet(dynamic value) => _stringList(value).toSet();

List<T> _objectList<T>(
  dynamic value,
  T Function(Map<String, dynamic>) parser,
) {
  if (value == null) {
    return const [];
  }
  return (value as List<dynamic>)
      .map((item) => parser(item as Map<String, dynamic>))
      .toList();
}
