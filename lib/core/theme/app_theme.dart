import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette — "Aydınlık Editorial" (calm, airy, ink + sage).
/// No neon, no glass: warm neutral surfaces, hairline dividers, soft pastels.
class AppColors {
  AppColors._();

  // Light Mode (paper-white, warm neutral)
  static const Color background = Color(0xFFFCFCFB); // Near-white warm paper
  static const Color surface = Color(0xFFF4F3F0); // Faint warm grey
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFFFFFF);

  // Dark Mode (matte charcoal, NOT pitch black, warm tint)
  static const Color darkBackground = Color(0xFF171614); // Warm near-black
  static const Color darkSurface = Color(0xFF1F1E1B); // Warm charcoal
  static const Color darkCard = Color(0xFF232220);
  static const Color darkCardElevated = Color(0xFF2A2926);

  // Primary accent — calm sage green (editorial, low saturation)
  static const Color teal = Color(0xFF5B7C6A); // Sage (brand, replaces emerald)
  static const Color tealDim = Color(0xFF4A6857);
  static const Color tealGlow = Color(0xFF6E9079); // Slightly lighter sage
  static const Color emeraldDeep = Color(0xFF3C5447); // Deep sage
  // Secondary — muted clay (used sparingly)
  static const Color violet = Color(0xFF9A7B6B); // Warm taupe (replaces indigo)
  static const Color violetDim = Color(0xFF856657);

  // Text Light Mode (ink)
  static const Color textPrimary = Color(0xFF1C1A17); // Warm ink
  static const Color textSecondary = Color(0xFF6E6A63); // Warm grey
  static const Color textTertiary = Color(0xFFA8A39B); // Light warm grey

  // Text Dark Mode
  static const Color darkTextPrimary = Color(0xFFF2F0EC);
  static const Color darkTextSecondary = Color(0xFFA8A39B);
  static const Color darkTextTertiary = Color(0xFF6E6A63);

  // Dividers / hairlines
  static const Color divider = Color(0xFFEAE8E3);
  static const Color darkDivider = Color(0xFF302E2A);

  // Soft pastel category palette (muted, harmonious — no raw colors)
  static const Color pastelTerracotta = Color(0xFFD08C7A); // was coral
  static const Color pastelBlue = Color(0xFF8AA9C2); // dusty blue
  static const Color pastelAmber = Color(0xFFD7A86E); // soft amber
  static const Color pastelPlum = Color(0xFF9B8AAE); // muted plum (was indigo)
  static const Color pastelLavender = Color(0xFFAE9BC4); // soft lavender
  static const Color pastelSage = Color(0xFF7FA38B); // soft sage (was teal)

  // Legacy alias kept for code that references it
  static const Color glassBorderLight = divider;
  static const Color glassBorderDark = darkDivider;
  static const Color glowTeal = teal;

  // Soft elevation shadow color
  static const Color shadow = Color(0x0F000000); // ~6% black

  // States
  static const Color success = Color(0xFF5B7C6A); // sage (matches brand)
  static const Color error = Color(0xFFC15F52); // muted brick red
  static const Color amber = Color(0xFFC79A4E); // muted gold (streak)
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
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      textTheme: _buildTextTheme(AppColors.textPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        modalBackgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.surface,
        border: AppColors.divider,
        hint: AppColors.textTertiary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.tealGlow,
        secondary: AppColors.violet,
        surface: AppColors.darkSurface,
        onPrimary: Color(0xFF12110F),
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
      ),
      textTheme: _buildTextTheme(AppColors.darkTextPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.tealGlow,
        foregroundColor: Color(0xFF12110F),
        elevation: 0,
        highlightElevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        modalBackgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
      ),
      inputDecorationTheme: _inputTheme(
        fill: AppColors.darkSurface,
        border: AppColors.darkDivider,
        hint: AppColors.darkTextTertiary,
      ),
    );
  }

  static InputDecorationTheme _inputTheme({
    required Color fill,
    required Color border,
    required Color hint,
  }) {
    return InputDecorationTheme(
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      hintStyle: TextStyle(color: hint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// Modern sans (Inter) across the board; hierarchy via weight/size/spacing.
  static TextTheme _buildTextTheme(Color textColor) {
    final base = TextTheme(
      displayLarge: _style(34, FontWeight.w800, -1.0, textColor, 1.15),
      displayMedium: _style(28, FontWeight.w800, -0.8, textColor, 1.2),
      displaySmall: _style(23, FontWeight.w700, -0.6, textColor, 1.25),
      headlineLarge: _style(20, FontWeight.w700, -0.4, textColor, 1.3),
      headlineMedium: _style(18, FontWeight.w700, -0.3, textColor, 1.3),
      headlineSmall: _style(16, FontWeight.w700, -0.2, textColor, 1.35),
      titleLarge: _style(16, FontWeight.w600, -0.2, textColor, 1.35),
      titleMedium: _style(14, FontWeight.w600, -0.1, textColor, 1.4),
      titleSmall: _style(12.5, FontWeight.w600, 0.0, textColor, 1.4),
      bodyLarge: _style(15, FontWeight.w400, 0.0, textColor, 1.5),
      bodyMedium: _style(13.5, FontWeight.w400, 0.0, textColor, 1.5),
      bodySmall: _style(11.5, FontWeight.w400, 0.1, textColor, 1.45),
      labelLarge: _style(13, FontWeight.w600, 0.0, textColor, 1.3),
      labelMedium: _style(11, FontWeight.w600, 0.2, textColor, 1.3),
      labelSmall: _style(9.5, FontWeight.w600, 0.4, textColor, 1.3),
    );
    return GoogleFonts.interTextTheme(base);
  }

  static TextStyle _style(
    double size,
    FontWeight weight,
    double letterSpacing,
    Color color,
    double height,
  ) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      letterSpacing: letterSpacing,
      color: color,
      height: height,
    );
  }
}

extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get textSecondaryColor =>
      isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textTertiaryColor =>
      isDarkMode ? AppColors.darkTextTertiary : AppColors.textTertiary;

  /// Very light, neutral editorial lift (no neon, no harsh black).
  List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.22 : 0.04),
          offset: const Offset(0, 4),
          blurRadius: 16,
          spreadRadius: -4,
        ),
      ];

  /// Surface fill for cards/chips. Optional accent [tint].
  Color glassFill([Color? tint]) {
    if (tint != null) {
      return tint.withValues(alpha: isDarkMode ? 0.16 : 0.10);
    }
    return isDarkMode ? AppColors.darkCard : AppColors.card;
  }

  /// Hairline border color (theme-aware).
  Color get glassBorder => isDarkMode ? AppColors.darkDivider : AppColors.divider;

  /// Editorial card decoration: clean fill + hairline border + optional lift.
  /// (Name kept for backward-compat; no glass/blur anymore.)
  BoxDecoration glassDecoration({
    Color? tint,
    double radius = 18,
    bool glow = false, // kept for compat; maps to a subtle lift
    Color? glowColor,
  }) {
    final hasTint = tint != null;
    return BoxDecoration(
      color: hasTint ? glassFill(tint) : glassFill(),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: hasTint ? tint.withValues(alpha: 0.30) : glassBorder,
        width: 1,
      ),
      boxShadow: glow || !hasTint ? softShadow : null,
    );
  }

  /// Backward-compat: returns a very subtle neutral lift (no glow).
  List<BoxShadow> glowShadow(Color color, {double strength = 1}) => softShadow;

  /// Soft tonal gradient for headers (almost flat, editorial).
  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? [AppColors.darkCard, AppColors.darkSurface]
            : [AppColors.surface, AppColors.background],
      );

  /// Subtle accent gradient (near-flat sage) for fills that ask for one.
  LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.tealGlow, AppColors.teal],
      );
}
