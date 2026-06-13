import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color palette — Premium "Neon Glass" (Emerald / Deep Neutral)
class AppColors {
  AppColors._();

  // Light Mode (clean white base)
  static const Color background = Color(0xFFFFFFFF); // Pure white base
  static const Color surface = Color(0xFFF6F8F7); // Faint cool grey
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFBFCFC);

  // Dark Mode (deep black-grey)
  static const Color darkBackground = Color(0xFF0A0C0E); // Near black
  static const Color darkSurface = Color(0xFF12161A); // Charcoal
  static const Color darkCard = Color(0xFF161B21);
  static const Color darkCardElevated = Color(0xFF1E252D);

  // Accents (emerald primary, indigo secondary)
  static const Color teal = Color(0xFF059669); // Emerald (brand)
  static const Color tealDim = Color(0xFF047857);
  static const Color tealGlow = Color(0xFF10B981); // Brighter emerald for glow/gradient
  static const Color emeraldDeep = Color(0xFF065F46); // Deep stop for gradients
  static const Color violet = Color(0xFF6366F1); // Indigo (secondary, sparing)
  static const Color violetDim = Color(0xFF4F46E5);

  // Text Light Mode
  static const Color textPrimary = Color(0xFF0F1729);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Text Dark Mode
  static const Color darkTextPrimary = Color(0xFFF3F5F7);
  static const Color darkTextSecondary = Color(0xFF9BA5B0);
  static const Color darkTextTertiary = Color(0xFF5C6672);

  // Dividers / Borders (subtle hairline)
  static const Color divider = Color(0xFFEAEDEF); // Light neutral border
  static const Color darkDivider = Color(0xFF252C34); // Dark neutral border

  // Glass: thin light edge on glass surfaces
  static const Color glassBorderLight = Color(0x14000000); // ~8% black edge (light theme)
  static const Color glassBorderDark = Color(0x1FFFFFFF); // ~12% white edge (dark theme)

  // Neon glow color
  static const Color glowTeal = Color(0xFF10B981);

  // Soft elevation shadow color
  static const Color shadow = Color(0x14000000); // ~8% black

  // States
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color amber = Color(0xFFF59E0B); // Streak / warning accent
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
          borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.divider, width: 1),
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
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.error,
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
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        modalBackgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.darkDivider, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
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
    // Modern sans-serif (Plus Jakarta Sans) applied to all text styles.
    final baseTheme = TextTheme(
      displayLarge: _style(32, FontWeight.w700, -0.5, textColor),
      displayMedium: _style(28, FontWeight.w700, -0.5, textColor),
      displaySmall: _style(22, FontWeight.w700, -0.3, textColor),
      headlineLarge: _style(20, FontWeight.w700, 0.0, textColor),
      headlineMedium: _style(18, FontWeight.w600, 0.0, textColor),
      headlineSmall: _style(16, FontWeight.w600, 0.0, textColor),
      titleLarge: _style(16, FontWeight.w600, 0.0, textColor),
      titleMedium: _style(14, FontWeight.w600, 0.0, textColor),
      titleSmall: _style(12, FontWeight.w600, 0.0, textColor),
      bodyLarge: _style(15, FontWeight.w500, 0.0, textColor),
      bodyMedium: _style(13, FontWeight.w500, 0.0, textColor),
      bodySmall: _style(11, FontWeight.w500, 0.0, textColor),
      labelLarge: _style(13, FontWeight.w600, 0.0, textColor),
      labelMedium: _style(11, FontWeight.w600, 0.0, textColor),
      labelSmall: _style(9, FontWeight.w600, 0.0, textColor),
    );

    return GoogleFonts.plusJakartaSansTextTheme(baseTheme);
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

extension AppThemeContext on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  Color get textSecondaryColor => isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get textTertiaryColor => isDarkMode ? AppColors.darkTextTertiary : AppColors.textTertiary;

  /// Subtle modern elevation shadow used across cards & raised surfaces.
  List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.05),
          offset: const Offset(0, 6),
          blurRadius: 18,
        ),
        if (!isDarkMode)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
      ];

  /// Translucent fill for frosted-glass surfaces. Optionally tinted with [tint].
  Color glassFill([Color? tint]) {
    if (tint != null) {
      return tint.withValues(alpha: isDarkMode ? 0.14 : 0.08);
    }
    return isDarkMode
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.white.withValues(alpha: 0.70);
  }

  /// Thin light edge that gives glass surfaces a crisp rim.
  Color get glassBorder =>
      isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight;

  /// Full glass decoration: translucent fill + light rim + layered shadow.
  /// Single source of truth for the frosted-card look across the app.
  BoxDecoration glassDecoration({
    Color? tint,
    double radius = 20,
    bool glow = false,
    Color? glowColor,
  }) {
    return BoxDecoration(
      color: glassFill(tint),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: tint != null
            ? tint.withValues(alpha: 0.35)
            : glassBorder,
        width: 1,
      ),
      boxShadow: [
        ...softShadow,
        if (glow) ...glowShadow(glowColor ?? AppColors.glowTeal),
      ],
    );
  }

  /// Colored neon glow used on active/completed elements & progress.
  List<BoxShadow> glowShadow(Color color, {double strength = 1}) => [
        BoxShadow(
          color: color.withValues(alpha: (isDarkMode ? 0.45 : 0.30) * strength),
          blurRadius: 24 * strength,
          spreadRadius: -2,
        ),
      ];

  /// Emerald hero gradient used behind screen headers (theme-aware).
  LinearGradient get heroGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDarkMode
            ? const [AppColors.emeraldDeep, Color(0xFF0A0C0E)]
            : const [AppColors.tealGlow, AppColors.teal],
      );

  /// Emerald accent gradient for buttons, rings, active chips.
  LinearGradient get accentGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.tealGlow, AppColors.tealDim],
      );
}
