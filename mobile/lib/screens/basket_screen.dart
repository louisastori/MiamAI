import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = MiamAiStateScope.of(context);
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) {
        final basket = state.basket;
        return Stack(
          children: [
            if (basket == null)
              const _EmptyBasket()
            else
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 190),
                children: [
                  AsyncMessage(message: state.errorMessage),
                  Text(
                    'Panier pour ${basket.recipeTitle}',
                    style: MiamAiText.headline
                        .copyWith(color: MiamAiColors.primary),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Vérifiez les ingrédients sélectionnés avant l'ajout au panier Leclerc.",
                    style: TextStyle(
                        fontSize: 16, color: MiamAiColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      NetworkPhoto(
                        url: basket.heroImageUrl,
                        width: double.infinity,
                        height: 190,
                        borderRadius: 16,
                      ),
                      Positioned(
                        left: 16,
                        bottom: 16,
                        child: Text(
                          basket.recipeTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...basket.lines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BasketLineCard(
                        line: line,
                        onChange: () => _showAlternatives(context, state, line),
                      ),
                    ),
                  ),
                ],
              ),
            if (basket != null)
              _BasketBottomBar(controller: _controller, basket: basket),
            LoadingLayer(visible: state.isBusy),
          ],
        );
      },
    );
  }

  Future<void> _showAlternatives(
    BuildContext context,
    MiamAiAppState state,
    BasketLine line,
  ) {
    // Les alternatives sont conservées dans chaque ligne de panier :
    // l'utilisateur peut changer de produit sans relancer une recherche.
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            shrinkWrap: true,
            children: [
              Text(
                'Changer ${line.ingredientName}',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              ...line.alternatives.map(
                (offer) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                  leading:
                      NetworkPhoto(url: offer.imageUrl, width: 58, height: 58),
                  title: Text(offer.title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(offer.packageSize),
                  trailing: Text(
                    formatPrice(offer.price),
                    style: const TextStyle(
                      color: MiamAiColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  enabled: offer.available,
                  onTap: () async {
                    await state.chooseAlternative(line, offer);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BasketLineCard extends StatelessWidget {
  const _BasketLineCard({
    required this.line,
    required this.onChange,
  });

  final BasketLine line;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final product = line.selectedProduct;
    return SectionCard(
      child: Row(
        children: [
          NetworkPhoto(url: product.imageUrl, width: 82, height: 82),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.displayCategory,
                        style: const TextStyle(
                            color: MiamAiColors.onSurfaceVariant),
                      ),
                    ),
                    Text(
                      formatPrice(line.lineTotal),
                      style: const TextStyle(
                        color: MiamAiColors.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      product.available ? Icons.check_circle : Icons.error,
                      color: product.available
                          ? MiamAiColors.tertiaryContainer
                          : MiamAiColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        product.available ? 'Sélectionné' : 'Indisponible',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: product.available
                              ? MiamAiColors.tertiaryContainer
                              : MiamAiColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onChange,
                      child: const Text('Changer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BasketBottomBar extends StatelessWidget {
  const _BasketBottomBar({
    required this.controller,
    required this.basket,
  });

  final TextEditingController controller;
  final Basket basket;

  @override
  Widget build(BuildContext context) {
    final state = MiamAiStateScope.of(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(
          color: MiamAiColors.surfaceContainerLowest,
          border: Border(top: BorderSide(color: MiamAiColors.surfaceVariant)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total (${basket.lines.length} articles)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatPrice(basket.totalPrice),
                  maxLines: 1,
                  style: const TextStyle(
                    color: MiamAiColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: basket.valid
                  ? () async {
                      final message = await state.handoffBasket();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(message)));
                      }
                    }
                  : null,
              icon: const Icon(Icons.shopping_cart),
              label: const FittedBox(child: Text('Ajouter au panier Leclerc')),
            ),
            const SizedBox(height: 10),
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                children: [
                  const Icon(Icons.smart_toy_outlined,
                      color: MiamAiColors.outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        hintText:
                            "Pose ta question... (ex: 'Prends moins cher')",
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onSubmitted: (_) => _send(state),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: () => _send(state),
                    icon: const Icon(Icons.send),
                    style: IconButton.styleFrom(
                      backgroundColor: MiamAiColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send(MiamAiAppState state) {
    final message = controller.text;
    controller.clear();
    state.sendMessage(message);
  }
}

class _EmptyBasket extends StatelessWidget {
  const _EmptyBasket();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SectionCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  size: 42, color: MiamAiColors.primary),
              const SizedBox(height: 12),
              const Text(
                'Aucun panier préparé',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Choisissez une recette depuis l’assistant pour rechercher les produits Leclerc.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
