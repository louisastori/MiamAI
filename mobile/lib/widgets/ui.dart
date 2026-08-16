import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

String formatPrice(double value) =>
    '${value.toStringAsFixed(2).replaceAll('.', ',')} €';

class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: MiamAiColors.surfaceContainerLowest,
        border: Border.all(color: MiamAiColors.surfaceVariant),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class AsyncMessage extends StatelessWidget {
  const AsyncMessage({required this.message, super.key});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (message == null) {
      return const SizedBox.shrink();
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message!,
        style: const TextStyle(
            color: Color(0xFF93000A), fontWeight: FontWeight.w600),
      ),
    );
  }
}

class NetworkPhoto extends StatelessWidget {
  const NetworkPhoto({
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 12,
    super.key,
  });

  final String url;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: MiamAiColors.surfaceContainer,
            alignment: Alignment.center,
            child: const Icon(Icons.restaurant, color: MiamAiColors.primary),
          );
        },
      ),
    );
  }
}

class LoadingLayer extends StatelessWidget {
  const LoadingLayer({required this.visible, super.key});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return const Positioned.fill(
      child: ColoredBox(
        color: Color(0x33FFFFFF),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
