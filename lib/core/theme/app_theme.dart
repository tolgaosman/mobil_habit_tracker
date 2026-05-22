import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette — Retro Arcade / Game Boy aesthetic
class AppColors {
  AppColors._();

  // Light Mode (Playful Retro Game Boy/NES)
  static const Color background = Color(0xFFF9F5EB); // Soft retro cream
  static const Color surface = Color(0xFFECE5D3); // Warm console sand
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFDFD7C0);

  // Dark Mode (Cyberpunk Synthwave Arcade)
  static const Color darkBackground = Color(0xFF120E22); // Retro neon dark purple
  static const Color darkSurface = Color(0xFF211B3D); // Console deep violet
  static const Color darkCard = Color(0xFF2C2450); // Dark arcade slot card
  static const Color darkCardElevated = Color(0xFF3B3169);

  // Accents
  static const Color teal = Color(0xFFFFC01C); // Sunny Coin Yellow
  static const Color tealDim = Color(0xFFE0A30B);
  static const Color violet = Color(0xFFFF5252); // NES controller red/coral
  static const Color violetDim = Color(0xFFE03A3A);

  // Text Light Mode
  static const Color textPrimary = Color(0xFF1E1A17); // Pixel solid black
  static const Color textSecondary = Color(0xFF5A524D); // Gameboy grey
  static const Color textTertiary = Color(0xFF9A8F85);

  // Text Dark Mode
  static const Color darkTextPrimary = Color(0xFF00FFD1); // Neon Cyan
  static const Color darkTextSecondary = Color(0xFFFF007F); // Neon Magenta
  static const Color darkTextTertiary = Color(0xFF8672C9);

  // Dividers / Borders
  static const Color divider = Color(0xFF1E1A17); // Thick black outline
  static const Color darkDivider = Color(0xFF00FFD1); // Neon cyan borders

  // States
  static const Color success = Color(0xFF53B175);
  static const Color error = Color(0xFFFC5C65);
}

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.teal,
        secondary: AppColors.violet,
        surface: AppColors.surface,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        error: Colors.redAccent,
      ),
      textTheme: _buildTextTheme(AppColors.textPrimary, true),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.divider, width: 2.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 2.5,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.black,
        elevation: 0,
        highlightElevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        modalBackgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: AppColors.divider, width: 3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 2.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider, width: 3),
        ),
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.teal,
        secondary: AppColors.violet,
        surface: AppColors.darkSurface,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        error: Colors.redAccent,
      ),
      textTheme: _buildTextTheme(AppColors.darkTextPrimary, false),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkDivider, width: 2.5),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 2.5,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.black,
        elevation: 0,
        highlightElevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          side: BorderSide(color: AppColors.darkDivider, width: 3),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider, width: 2.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider, width: 2.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkDivider, width: 3),
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextTertiary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color textColor, bool isLight) {
    // Wrap with GoogleFonts.pixelifySans to apply the retro arcade font to all styles
    final baseTheme = TextTheme(
      displayLarge: _style(32, FontWeight.w800, -0.5, textColor),
      displayMedium: _style(28, FontWeight.w800, -0.5, textColor),
      displaySmall: _style(22, FontWeight.w700, 0.0, textColor),
      headlineLarge: _style(20, FontWeight.w700, 0.0, textColor),
      headlineMedium: _style(18, FontWeight.w700, 0.0, textColor),
      headlineSmall: _style(16, FontWeight.w700, 0.0, textColor),
      titleLarge: _style(16, FontWeight.w700, 0.0, textColor),
      titleMedium: _style(14, FontWeight.w700, 0.0, textColor),
      titleSmall: _style(12, FontWeight.w700, 0.0, textColor),
      bodyLarge: _style(15, FontWeight.w600, 0.0, textColor),
      bodyMedium: _style(13, FontWeight.w600, 0.0, textColor),
      bodySmall: _style(11, FontWeight.w600, 0.0, textColor),
      labelLarge: _style(13, FontWeight.w700, 0.0, textColor),
      labelMedium: _style(11, FontWeight.w700, 0.0, textColor),
      labelSmall: _style(9, FontWeight.w700, 0.0, textColor),
    );

    return GoogleFonts.pixelifySansTextTheme(baseTheme);
  }

  static TextStyle _style(
    double size,
    FontWeight weight,
    double letterSpacing,
    Color color,
  ) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color,
      height: 1.4,
    );
  }
}
