import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({required this.driveName, super.key});

  final String driveName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: MiamAiColors.surface.withValues(alpha: 0.92),
        border: const Border(bottom: BorderSide(color: Color(0x1AE0E3E5))),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant, color: MiamAiColors.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Assistant cuisine',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: MiamAiColors.primary,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              driveName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: MiamAiColors.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.location_on,
              size: 20, color: MiamAiColors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class MiamAiBottomNavigation extends StatelessWidget {
  const MiamAiBottomNavigation({
    required this.currentIndex,
    required this.onSelected,
    required this.basketCount,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onSelected;
  final int basketCount;

  @override
  Widget build(BuildContext context) {
    // Libellés francisés même si la maquette exportée contenait encore
    // des intitulés anglais.
    return NavigationBar(
      height: 72,
      selectedIndex: currentIndex,
      onDestinationSelected: onSelected,
      backgroundColor: MiamAiColors.surface.withValues(alpha: 0.96),
      indicatorColor: const Color(0xFFD7E3FF),
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble, color: MiamAiColors.primary),
          label: 'Assistant',
        ),
        const NavigationDestination(
          icon: Icon(Icons.calendar_month_outlined),
          selectedIcon: Icon(Icons.calendar_month, color: MiamAiColors.primary),
          label: 'Mes repas',
        ),
        NavigationDestination(
          icon: _BasketIcon(count: basketCount, selected: false),
          selectedIcon: _BasketIcon(count: basketCount, selected: true),
          label: 'Panier',
        ),
        const NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings, color: MiamAiColors.primary),
          label: 'Paramètres',
        ),
      ],
    );
  }
}

class _BasketIcon extends StatelessWidget {
  const _BasketIcon({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          selected ? Icons.shopping_bag : Icons.shopping_bag_outlined,
          color: selected ? MiamAiColors.primary : null,
        ),
        if (count > 0)
          Positioned(
            right: -8,
            top: -7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: const BoxDecoration(
                color: MiamAiColors.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Text(
                count.toString(),
                style:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ],
    );
  }
}
