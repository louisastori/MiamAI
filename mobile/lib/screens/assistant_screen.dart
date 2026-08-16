import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';
import 'recipe_sheet.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({required this.onOpenBasket, super.key});

  final VoidCallback onOpenBasket;

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
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
        return Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 172),
              children: [
                AsyncMessage(message: state.errorMessage),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: MiamAiColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      "Aujourd'hui",
                      style: TextStyle(
                          color: MiamAiColors.onSurfaceVariant, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const _UserBubble(
                  text:
                      'Je veux manger asiatique ce soir, pour 3 personnes, pas trop compliqué.',
                ),
                const SizedBox(height: 26),
                _AssistantBubble(text: state.lastAssistantMessage),
                const SizedBox(height: 16),
                if (state.proposals.isEmpty) const _EmptyAssistantState(),
                if (state.proposals.isNotEmpty)
                  SizedBox(
                    height: 380,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.proposals.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final proposal = state.proposals[index];
                        return _RecipeProposalCard(
                          proposal: proposal,
                          onView: () => _openRecipe(context, state, proposal),
                          onChoose: () => _chooseRecipe(state, proposal),
                        );
                      },
                    ),
                  ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _AssistantComposer(
                controller: _controller,
                onShortcut: (message) => state.sendMessage(message),
                onSend: () {
                  final message = _controller.text;
                  _controller.clear();
                  state.sendMessage(message);
                },
              ),
            ),
            LoadingLayer(visible: state.isBusy),
          ],
        );
      },
    );
  }

  Future<void> _openRecipe(
    BuildContext context,
    MiamAiAppState state,
    RecipeProposal proposal,
  ) async {
    final recipe = await state.selectRecipe(proposal);
    if (recipe == null || !context.mounted) {
      return;
    }
    await showRecipeDetailSheet(
      context: context,
      recipe: recipe,
      onPrepareBasket: () async {
        await state.prepareBasket();
        widget.onOpenBasket();
      },
    );
  }

  Future<void> _chooseRecipe(
      MiamAiAppState state, RecipeProposal proposal) async {
    // Parcours rapide : le bouton "Choisir" sélectionne la recette
    // puis prépare immédiatement le panier Leclerc simulé.
    await state.selectRecipe(proposal);
    await state.prepareBasket();
    widget.onOpenBasket();
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: MiamAiColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
            topRight: Radius.circular(6),
          ),
        ),
        child: Text(
          text,
          style:
              const TextStyle(color: Colors.white, fontSize: 18, height: 1.35),
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundColor: MiamAiColors.surfaceContainer,
          child: Icon(Icons.restaurant, color: MiamAiColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SectionCard(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, height: 1.45),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyAssistantState extends StatelessWidget {
  const _EmptyAssistantState();

  @override
  Widget build(BuildContext context) {
    final state = MiamAiStateScope.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 54, top: 8),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Demande une idée de repas ou utilise un raccourci.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => state.sendMessage(
                'Je veux manger asiatique ce soir, pour 3 personnes, pas trop compliqué.',
              ),
              child: const Text('Essayer une recette'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeProposalCard extends StatelessWidget {
  const _RecipeProposalCard({
    required this.proposal,
    required this.onView,
    required this.onChoose,
  });

  final RecipeProposal proposal;
  final VoidCallback onView;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 302,
      child: SectionCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                NetworkPhoto(
                  url: proposal.imageUrl,
                  width: double.infinity,
                  height: 132,
                  borderRadius: 16,
                ),
                if (proposal.nutriScore != null)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.eco_outlined,
                              size: 16, color: MiamAiColors.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            'Nutri ${proposal.nutriScore}',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proposal.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined,
                          size: 18, color: MiamAiColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${proposal.prepTimeMinutes} min'),
                      const SizedBox(width: 14),
                      const Icon(Icons.group_outlined,
                          size: 18, color: MiamAiColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('${proposal.servings} pers'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '~${formatPrice(proposal.estimatedCost)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MiamAiColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onView,
                          child: const Text('Voir'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: onChoose,
                          style: FilledButton.styleFrom(
                            backgroundColor: MiamAiColors.secondary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const FittedBox(child: Text('Choisir')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantComposer extends StatelessWidget {
  const _AssistantComposer({
    required this.controller,
    required this.onShortcut,
    required this.onSend,
  });

  final TextEditingController controller;
  final ValueChanged<String> onShortcut;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, 12 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00F7F9FB),
            MiamAiColors.background,
            MiamAiColors.background
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _QuickChip(
                    label: 'Ce soir',
                    icon: Icons.dinner_dining,
                    onTap: () => onShortcut('Je veux une idée pour ce soir')),
                _QuickChip(
                    label: 'Semaine',
                    icon: Icons.calendar_month,
                    onTap: () => onShortcut(
                        'Fais-moi 5 repas pour 3 personnes avec 60 euros maximum')),
                _QuickChip(
                    label: 'Petit budget',
                    icon: Icons.savings_outlined,
                    onTap: () => onShortcut(
                        'Je veux un repas asiatique petit budget pour 3 personnes')),
                _QuickChip(
                    label: 'Rapide',
                    icon: Icons.bolt,
                    onTap: () =>
                        onShortcut('Je veux un repas rapide pour 3 personnes')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SectionCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.mic_none, color: MiamAiColors.primary),
                ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Pose ta question...',
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onSubmitted: (_) => onSend(),
                  ),
                ),
                IconButton.filled(
                  onPressed: onSend,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: MiamAiColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 18, color: MiamAiColors.onSurfaceVariant),
        label: Text(label),
        onPressed: onTap,
        side: const BorderSide(color: MiamAiColors.surfaceVariant),
        backgroundColor: MiamAiColors.surfaceContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}
