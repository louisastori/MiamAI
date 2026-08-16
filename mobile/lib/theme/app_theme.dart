import 'package:flutter/material.dart';

class MiamAiColors {
  static const background = Color(0xFFF7F9FB);
  static const surface = Color(0xFFF7F9FB);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F6);
  static const surfaceContainer = Color(0xFFECEEF0);
  static const surfaceVariant = Color(0xFFE0E3E5);
  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF414753);
  static const outline = Color(0xFF727784);
  static const outlineVariant = Color(0xFFC1C6D5);
  static const primary = Color(0xFF004E9F);
  static const primaryContainer = Color(0xFF0066CC);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFF8F4D00);
  static const secondaryContainer = Color(0xFFFF8E04);
  static const onSecondaryContainer = Color(0xFF623300);
  static const tertiary = Color(0xFF005E27);
  static const tertiaryContainer = Color(0xFF007934);
  static const error = Color(0xFFBA1A1A);
}

ThemeData buildMiamAiTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    colorScheme: const ColorScheme.light(
      primary: MiamAiColors.primary,
      onPrimary: MiamAiColors.onPrimary,
      secondary: MiamAiColors.secondaryContainer,
      surface: MiamAiColors.surface,
      error: MiamAiColors.error,
      onSurface: MiamAiColors.onSurface,
    ),
    scaffoldBackgroundColor: MiamAiColors.background,
    textTheme: base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: MiamAiColors.onSurface,
      displayColor: MiamAiColors.onSurface,
    ),
    cardTheme: CardThemeData(
      color: MiamAiColors.surfaceContainerLowest,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: MiamAiColors.surfaceVariant),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MiamAiColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MiamAiColors.surfaceVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MiamAiColors.surfaceVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: MiamAiColors.primary, width: 1.4),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        backgroundColor: MiamAiColors.secondaryContainer,
        foregroundColor: MiamAiColors.onSecondaryContainer,
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: MiamAiColors.primary,
        side: const BorderSide(color: MiamAiColors.primary, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: MiamAiColors.surfaceContainerLowest,
      contentTextStyle: const TextStyle(
        color: MiamAiColors.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class MiamAiText {
  static const headline = TextStyle(
    fontSize: 30,
    height: 36 / 30,
    fontWeight: FontWeight.w700,
  );

  static const title = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const label = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w700,
  );
}
