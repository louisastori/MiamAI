import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = MiamAiStateScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final meals = state.meals;
        if (meals == null) {
          return const Center(child: CircularProgressIndicator());
        }
        // La semaine est affichée comme une sélection prête à ajuster.
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
          children: [
            Text(meals.title, style: MiamAiText.headline),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFD7E3FF),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${meals.mealCount} repas · ~${formatPrice(meals.estimatedTotal)}',
                  style: const TextStyle(
                    color: MiamAiColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            ...meals.meals.map((meal) => _MealCard(meal: meal)),
            const SizedBox(height: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier'),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Panier semaine préparé : ${meals.mealCount} repas pour environ ${formatPrice(meals.estimatedTotal)}.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Créer le panier'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final MealPlanItem meal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: MiamAiColors.surfaceContainerLowest,
          border: Border.all(
            color: meal.selected
                ? const Color(0x334E9FFF)
                : MiamAiColors.surfaceVariant,
            width: meal.selected ? 1.4 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 116,
              decoration: BoxDecoration(
                color: meal.selected
                    ? MiamAiColors.primary
                    : MiamAiColors.surfaceVariant,
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: meal.selected
                            ? const Color(0xFFD7E3FF)
                            : MiamAiColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        meal.selected
                            ? Icons.restaurant_menu
                            : Icons.dinner_dining,
                        color: meal.selected
                            ? MiamAiColors.primary
                            : MiamAiColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  meal.day.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: meal.selected
                                        ? MiamAiColors.primary
                                        : MiamAiColors.outline,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const Icon(Icons.schedule,
                                  size: 16,
                                  color: MiamAiColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                '${meal.prepTimeMinutes} min',
                                style: const TextStyle(
                                    color: MiamAiColors.onSurfaceVariant),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            meal.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: meal.ingredientTags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: MiamAiColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(tag,
                                    style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                          meal.selected ? Icons.swap_horiz : Icons.more_vert),
                      color: meal.selected
                          ? MiamAiColors.primary
                          : MiamAiColors.outline,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
