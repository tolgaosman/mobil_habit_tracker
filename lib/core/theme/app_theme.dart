import 'package:flutter/material.dart';

/// App color palette — deep dark theme with neon teal accent
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0D0D0F);
  static const Color surface = Color(0xFF161618);
  static const Color card = Color(0xFF1C1C1F);
  static const Color cardElevated = Color(0xFF242428);

  // Accents
  static const Color teal = Color(0xFF00E5C3);
  static const Color tealDim = Color(0xFF00C4A7);
  static const Color violet = Color(0xFF9B6DFF);
  static const Color violetDim = Color(0xFF7B4FD8);

  // Text
  static const Color textPrimary = Color(0xFFF1F1F1);
  static const Color textSecondary = Color(0xFF9A9A9E);
  static const Color textTertiary = Color(0xFF5A5A60);

  // States
  static const Color success = Color(0xFF00E5C3);
  static const Color error = Color(0xFFFF5F6D);
  static const Color divider = Color(0xFF2A2A2E);
}

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.teal,
        secondary: AppColors.violet,
        surface: AppColors.surface,
        onPrimary: AppColors.background,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardTheme(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: AppColors.background,
        elevation: 0,
        highlightElevation: 2,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.background;
          return AppColors.textTertiary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) return AppColors.teal;
          return AppColors.card;
        }),
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: _style(32, FontWeight.w700, -1.0),
      displayMedium: _style(28, FontWeight.w700, -0.8),
      displaySmall: _style(24, FontWeight.w600, -0.5),
      headlineLarge: _style(22, FontWeight.w600, -0.4),
      headlineMedium: _style(20, FontWeight.w600, -0.3),
      headlineSmall: _style(18, FontWeight.w600, -0.2),
      titleLarge: _style(17, FontWeight.w600, -0.2),
      titleMedium: _style(15, FontWeight.w500, -0.1),
      titleSmall: _style(13, FontWeight.w500, 0),
      bodyLarge: _style(16, FontWeight.w400, 0),
      bodyMedium: _style(14, FontWeight.w400, 0),
      bodySmall: _style(12, FontWeight.w400, 0.1),
      labelLarge: _style(14, FontWeight.w600, 0.2),
      labelMedium: _style(12, FontWeight.w600, 0.3),
      labelSmall: _style(10, FontWeight.w600, 0.4),
    );
  }

  static TextStyle _style(
    double size,
    FontWeight weight,
    double letterSpacing,
  ) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: AppColors.textPrimary,
      height: 1.4,
    );
  }
}
