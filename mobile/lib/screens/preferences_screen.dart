import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _excludedController = TextEditingController();
  PreferenceProfile? _syncedProfile;

  @override
  void dispose() {
    _budgetController.dispose();
    _excludedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = MiamAiStateScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final profile = state.preferences;
        if (profile == null) {
          return const Center(child: CircularProgressIndicator());
        }
        _syncControllers(profile);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 110),
          children: [
            const Text('Paramètres', style: MiamAiText.headline),
            const SizedBox(height: 18),
            _DriveCard(profile: profile),
            const SizedBox(height: 14),
            _FoodPreferencesCard(
              profile: profile,
              budgetController: _budgetController,
              onUpdate: state.updatePreferences,
            ),
            const SizedBox(height: 14),
            _EquipmentCard(profile: profile, onUpdate: state.updatePreferences),
            const SizedBox(height: 14),
            _NotificationsCard(
              profile: profile,
              excludedController: _excludedController,
              onUpdate: state.updatePreferences,
            ),
            const SizedBox(height: 14),
            const SectionCard(
              child: Column(
                children: [
                  Text(
                    'À propos',
                    style: TextStyle(
                      color: MiamAiColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text('Version 0.1.0'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _syncControllers(PreferenceProfile profile) {
    if (identical(_syncedProfile, profile)) {
      return;
    }
    _budgetController.text = profile.weeklyBudget.toStringAsFixed(0);
    _excludedController.text = profile.excludedIngredients.join(', ');
    _syncedProfile = profile;
  }
}

class _DriveCard extends StatelessWidget {
  const _DriveCard({required this.profile});

  final PreferenceProfile profile;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
              icon: Icons.storefront, text: 'Magasin Leclerc Drive'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MiamAiColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MiamAiColors.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.preferredDrive.name,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(
                        profile.preferredDrive.address,
                        style: const TextStyle(
                            color: MiamAiColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Modifier')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FoodPreferencesCard extends StatelessWidget {
  const _FoodPreferencesCard({
    required this.profile,
    required this.budgetController,
    required this.onUpdate,
  });

  final PreferenceProfile profile;
  final TextEditingController budgetController;
  final ValueChanged<PreferenceProfile> onUpdate;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          const _CardTitle(icon: Icons.tune, text: 'Préférences alimentaires'),
          const SizedBox(height: 12),
          _PreferenceRow(
            label: 'Nombre de personnes',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _RoundButton(
                  icon: Icons.remove,
                  onTap: profile.peopleCount <= 1
                      ? null
                      : () => onUpdate(profile.copyWith(
                          peopleCount: profile.peopleCount - 1)),
                ),
                SizedBox(
                  width: 34,
                  child: Text(
                    profile.peopleCount.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                _RoundButton(
                  icon: Icons.add,
                  onTap: () => onUpdate(
                      profile.copyWith(peopleCount: profile.peopleCount + 1)),
                ),
              ],
            ),
          ),
          _PreferenceRow(
            label: 'Budget hebdomadaire',
            trailing: SizedBox(
              width: 96,
              child: TextField(
                controller: budgetController,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  isDense: true,
                  suffixText: '€',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
                onSubmitted: (value) {
                  final budget = double.tryParse(value.replaceAll(',', '.'));
                  if (budget != null) {
                    onUpdate(profile.copyWith(weeklyBudget: budget));
                  }
                },
              ),
            ),
          ),
          _PreferenceRow(
            label: 'Régime par défaut',
            trailing: DropdownButton<String>(
              value: _dietModeValue(profile.defaultDietMode),
              items: const [
                DropdownMenuItem(value: 'Équilibré', child: Text('Équilibré')),
                DropdownMenuItem(
                    value: 'Économique', child: Text('Économique')),
                DropdownMenuItem(
                    value: 'Végétarien', child: Text('Végétarien')),
                DropdownMenuItem(
                    value: 'Sans gluten', child: Text('Sans gluten')),
              ],
              onChanged: (value) {
                if (value != null) {
                  onUpdate(profile.copyWith(defaultDietMode: value));
                }
              },
            ),
            showDivider: false,
          ),
        ],
      ),
    );
  }

  String _dietModeValue(String value) {
    return switch (value) {
      'Equilibre' => 'Équilibré',
      'Economique' => 'Économique',
      'Vegetarien' => 'Végétarien',
      _ => value,
    };
  }
}

class _EquipmentCard extends StatelessWidget {
  const _EquipmentCard({required this.profile, required this.onUpdate});

  final PreferenceProfile profile;
  final ValueChanged<PreferenceProfile> onUpdate;

  static const equipment = [
    'Friteuse à air',
    'Thermomix',
    'Cuiseur à riz',
    'Robot multifonction',
    'Four à chaleur tournante',
  ];

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        children: [
          const _CardTitle(icon: Icons.kitchen, text: 'Équipements de cuisine'),
          const SizedBox(height: 10),
          ...equipment.map(
            (item) => _SwitchRow(
              label: item,
              value: profile.kitchenEquipment.contains(item),
              onChanged: (enabled) {
                final next = {...profile.kitchenEquipment};
                enabled ? next.add(item) : next.remove(item);
                onUpdate(profile.copyWith(kitchenEquipment: next));
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationsCard extends StatelessWidget {
  const _NotificationsCard({
    required this.profile,
    required this.excludedController,
    required this.onUpdate,
  });

  final PreferenceProfile profile;
  final TextEditingController excludedController;
  final ValueChanged<PreferenceProfile> onUpdate;

  static const restrictions = {
    'Sans gluten': 'Sans gluten',
    'Végétarien': 'Végétarien',
    'Végan': 'Végan',
    'Sans lactose': 'Sans lactose',
  };

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
              icon: Icons.notifications_outlined,
              text: 'Alertes et notifications'),
          const SizedBox(height: 10),
          _SwitchRow(
            label: 'Rappels de planification',
            value: profile.planningReminders,
            onChanged: (value) =>
                onUpdate(profile.copyWith(planningReminders: value)),
          ),
          _SwitchRow(
            label: 'Promotions Leclerc',
            value: profile.leclercPromotions,
            onChanged: (value) =>
                onUpdate(profile.copyWith(leclercPromotions: value)),
          ),
          const Divider(height: 24),
          const Text(
            'RÉGIMES SPÉCIFIQUES',
            style: TextStyle(
              color: MiamAiColors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          ...restrictions.entries.map(
            (entry) => _SwitchRow(
              label: entry.value,
              value: profile.dietaryRestrictions.contains(entry.key),
              onChanged: (enabled) {
                final next = {...profile.dietaryRestrictions};
                enabled ? next.add(entry.key) : next.remove(entry.key);
                onUpdate(profile.copyWith(dietaryRestrictions: next));
              },
            ),
          ),
          const Divider(height: 24),
          const Text(
            'INGRÉDIENTS À EXCLURE',
            style: TextStyle(
              color: MiamAiColors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: excludedController,
            decoration: const InputDecoration(
              hintText: 'Ex: Coriandre, Oignons...',
              isDense: true,
            ),
            onSubmitted: (value) => onUpdate(
              profile.copyWith(
                excludedIngredients: value
                    .split(',')
                    .map((item) => item.trim())
                    .where((item) => item.isNotEmpty)
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: MiamAiColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: MiamAiColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.label,
    required this.trailing,
    this.showDivider = true,
  });

  final String label;
  final Widget trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(
                bottom: BorderSide(color: MiamAiColors.surfaceVariant))
            : null,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          trailing,
        ],
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: MiamAiColors.surfaceVariant)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      style: IconButton.styleFrom(
        minimumSize: const Size(36, 36),
        backgroundColor: MiamAiColors.surfaceContainer,
        foregroundColor: MiamAiColors.onSurface,
      ),
    );
  }
}
