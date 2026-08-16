import 'package:flutter/material.dart';

import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

Future<void> showRecipeDetailSheet({
  required BuildContext context,
  required RecipeDetail recipe,
  required Future<void> Function() onPrepareBasket,
}) {
  // La fiche recette reste en bottom sheet pour coller à la maquette
  // et permettre un retour rapide au chat.
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _RecipeDetailSheet(
      recipe: recipe,
      onPrepareBasket: onPrepareBasket,
    ),
  );
}

class _RecipeDetailSheet extends StatefulWidget {
  const _RecipeDetailSheet({
    required this.recipe,
    required this.onPrepareBasket,
  });

  final RecipeDetail recipe;
  final Future<void> Function() onPrepareBasket;

  @override
  State<_RecipeDetailSheet> createState() => _RecipeDetailSheetState();
}

class _RecipeDetailSheetState extends State<_RecipeDetailSheet> {
  final Set<String> _checkedIngredients = {};
  final Set<int> _checkedSteps = {};

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: MiamAiColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    _Hero(recipe: recipe),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(recipe.title,
                                    style: MiamAiText.headline),
                              ),
                              if (recipe.nutriScore != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: MiamAiColors.tertiaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Nutri-Score ${recipe.nutriScore}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _Meta(
                                  icon: Icons.group_outlined,
                                  label: '${recipe.servings} personnes'),
                              const SizedBox(width: 28),
                              _Meta(
                                  icon: Icons.schedule,
                                  label: '${recipe.prepTimeMinutes} min'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (recipe.nutrition != null)
                            _NutritionBlock(nutrition: recipe.nutrition!),
                          const SizedBox(height: 24),
                          Text('Ingrédients',
                              style:
                                  MiamAiText.headline.copyWith(fontSize: 28)),
                          const SizedBox(height: 12),
                          ...recipe.ingredients.map(_ingredientRow),
                          const SizedBox(height: 24),
                          Text('Préparation',
                              style:
                                  MiamAiText.headline.copyWith(fontSize: 24)),
                          const SizedBox(height: 16),
                          ...recipe.steps.map(_stepRow),
                          const SizedBox(height: 24),
                          _ChefTips(tips: recipe.chefTips),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  16 + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: const BoxDecoration(
                  color: MiamAiColors.surfaceContainerLowest,
                  border: Border(
                      top: BorderSide(color: MiamAiColors.surfaceVariant)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Panier estimé',
                          style: TextStyle(
                              color: MiamAiColors.onSurfaceVariant,
                              fontSize: 16),
                        ),
                        const Spacer(),
                        Text(
                          formatPrice(recipe.estimatedBasketCost),
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await widget.onPrepareBasket();
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Préparer le panier'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ingredientRow(IngredientRequirement ingredient) {
    final checked = _checkedIngredients.contains(ingredient.key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          setState(() {
            checked
                ? _checkedIngredients.remove(ingredient.key)
                : _checkedIngredients.add(ingredient.key);
          });
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: MiamAiColors.surfaceContainerLow,
            border: Border.all(color: MiamAiColors.surfaceVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _CheckCircle(checked: checked),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  ingredient.name,
                  style: TextStyle(
                    fontSize: 18,
                    decoration: checked ? TextDecoration.lineThrough : null,
                    color:
                        checked ? MiamAiColors.outline : MiamAiColors.onSurface,
                  ),
                ),
              ),
              Text(
                ingredient.displayQuantity,
                style: const TextStyle(
                    fontSize: 16, color: MiamAiColors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepRow(RecipeStep step) {
    final checked = _checkedSteps.contains(step.order);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: () {
          setState(() {
            checked
                ? _checkedSteps.remove(step.order)
                : _checkedSteps.add(step.order);
          });
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: checked
                  ? MiamAiColors.tertiaryContainer
                  : MiamAiColors.primaryContainer,
              child: Text(
                step.order.toString(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                step.text,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                  decoration: checked ? TextDecoration.lineThrough : null,
                  color:
                      checked ? MiamAiColors.outline : MiamAiColors.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.recipe});

  final RecipeDetail recipe;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NetworkPhoto(
          url: recipe.imageUrl,
          height: 260,
          width: double.infinity,
          borderRadius: 0,
        ),
        Positioned(
          top: 18,
          right: 18,
          child: IconButton.filled(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.88)),
          ),
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: MiamAiColors.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(
                color: MiamAiColors.onSurfaceVariant, fontSize: 18)),
      ],
    );
  }
}

class _NutritionBlock extends StatelessWidget {
  const _NutritionBlock({required this.nutrition});

  final Nutrition nutrition;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Valeurs nutritionnelles (par portion)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        SectionCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NutritionItem(
                  label: 'Calories', value: '${nutrition.caloriesKcal} kcal'),
              _NutritionItem(
                  label: 'Protéines', value: '${nutrition.proteinGrams}g'),
              _NutritionItem(
                  label: 'Glucides', value: '${nutrition.carbsGrams}g'),
              _NutritionItem(label: 'Lipides', value: '${nutrition.fatGrams}g'),
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionItem extends StatelessWidget {
  const _NutritionItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: MiamAiColors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(value,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: checked ? MiamAiColors.tertiaryContainer : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: checked
              ? MiamAiColors.tertiaryContainer
              : MiamAiColors.outlineVariant,
          width: 2,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, color: Colors.white, size: 18)
          : null,
    );
  }
}

class _ChefTips extends StatelessWidget {
  const _ChefTips({required this.tips});

  final List<String> tips;

  @override
  Widget build(BuildContext context) {
    if (tips.isEmpty) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MiamAiColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: MiamAiColors.primary),
              SizedBox(width: 8),
              Text('Conseils du chef',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('• $tip',
                  style: const TextStyle(color: MiamAiColors.onSurfaceVariant)),
            ),
          ),
        ],
      ),
    );
  }
}
