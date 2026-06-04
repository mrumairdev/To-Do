import 'package:flutter/material.dart';

import 'app_theme_variant.dart';

class AppTheme {
  static const Color _seedColor = Color(0xFF0F766E);
  static const Color _blueSeedColor = Color(0xFF2563EB);

  static ThemeData themeFor(AppThemeVariant variant) => switch (variant) {
        AppThemeVariant.light => lightTheme,
        AppThemeVariant.dark => darkTheme,
        AppThemeVariant.blueAccent => blueAccentTheme,
      };

  static ThemeData get lightTheme => _buildTheme(
        seedColor: _seedColor,
        brightness: Brightness.light,
        scaffoldColor: const Color(0xFFF6F7F9),
        cardColor: Colors.white,
        inputFillColor: Colors.white,
      );

  static ThemeData get darkTheme => _buildTheme(
        seedColor: _seedColor,
        brightness: Brightness.dark,
        scaffoldColor: const Color(0xFF0B1220),
        cardColor: const Color(0xFF111827),
        inputFillColor: const Color(0xFF111827),
      );

  static ThemeData get blueAccentTheme => _buildTheme(
        seedColor: _blueSeedColor,
        brightness: Brightness.light,
        scaffoldColor: const Color(0xFFEFF6FF),
        cardColor: const Color(0xFFF8FAFC),
        inputFillColor: const Color(0xFFF8FAFC),
        appBarColor: const Color(0xFF1D4ED8),
        appBarForeground: Colors.white,
      );

  static ThemeData _buildTheme({
    required Color seedColor,
    required Brightness brightness,
    required Color scaffoldColor,
    required Color cardColor,
    required Color inputFillColor,
    Color? appBarColor,
    Color? appBarForeground,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: appBarColor,
        foregroundColor: appBarForeground,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: inputFillColor,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
