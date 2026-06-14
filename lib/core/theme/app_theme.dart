import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// DESIGN TOKENS — "Aydınlık Editorial"
// ----------------------------------------------------------------------------
// Single source of truth for the visual language. Pull from these tokens
// instead of hard-coding values, so the look stays consistent and tunable.
//
//   • Color      → AppColors      (surfaces, sage accent, muted pastels, text,
//                                   dividers, states). Names are kept stable for
//                                   back-compat; values are the editorial sage set.
//   • Spacing    → AppSpacing     (4-pt rhythm: xs 4 · sm 8 · md 12 · lg 16 ·
//                                   xl 20 · xxl 24)
//   • Radius     → AppRadius      (sm 8 · md 12 · lg 16 · sheet 20)
//   • Typography → AppTheme text  (Inter scale, weight/size/tracking hierarchy)
//   • Elevation  → context.softShadow / context.glassDecoration()  (soft diffuse
//                                   lift in light mode, surface contrast in dark)
//
// Decoration helpers live on the `AppThemeContext` extension at the bottom of
// this file (glassDecoration / glassFill / glassBorder / softShadow / gradients).
// Reusable components built on these tokens live in widgets/glass.dart.
// ============================================================================

/// App color palette — neutral iOS-system feel + a single calm sage accent.
/// Cool neutral greys (systemGroupedBackground-like), hairline separators,
/// one tint. Muted pastels stay for per-habit category color only.
class AppColors {
  AppColors._();

  // Light Mode (iOS systemGroupedBackground / secondary surfaces)
  static const Color background = Color(0xFFF2F2F7); // grouped background
  static const Color surface = Color(0xFFE9E9EE); // faint neutral grey
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardElevated = Color(0xFFFFFFFF);

  // Dark Mode (iOS grouped dark surfaces)
  static const Color darkBackground = Color(0xFF000000); // true grouped base
  static const Color darkSurface = Color(0xFF1C1C1E); // secondary surface
  static const Color darkCard = Color(0xFF1C1C1E);
  static const Color darkCardElevated = Color(0xFF2C2C2E);

  // Primary accent — calm sage green (single system tint)
  static const Color teal = Color(0xFF5B7C6A);
  static const Color tealDim = Color(0xFF4A6857);
  static const Color tealGlow = Color(0xFF7FA38B); // lighter sage (dark-mode tint)
  static const Color emeraldDeep = Color(0xFF3C5447);
  // Secondary — muted clay (used sparingly)
  static const Color violet = Color(0xFF9A7B6B);
  static const Color violetDim = Color(0xFF856657);

  // Text Light Mode (iOS label tones, neutral)
  static const Color textPrimary = Color(0xFF1C1C1E); // label
  static const Color textSecondary = Color(0xFF6C6C70); // secondaryLabel ~60%
  static const Color textTertiary = Color(0xFFAEAEB2); // tertiaryLabel

  // Text Dark Mode
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF98989F);
  static const Color darkTextTertiary = Color(0xFF636366);

  // Separators (iOS separator / opaqueSeparator, neutral)
  static const Color divider = Color(0xFFD9D9DE);
  static const Color darkDivider = Color(0xFF38383A);

  // Soft pastel category palette (per-habit color only — muted, harmonious)
  static const Color pastelTerracotta = Color(0xFFD08C7A);
  static const Color pastelBlue = Color(0xFF8AA9C2);
  static const Color pastelAmber = Color(0xFFD7A86E);
  static const Color pastelPlum = Color(0xFF9B8AAE);
  static const Color pastelLavender = Color(0xFFAE9BC4);
  static const Color pastelSage = Color(0xFF7FA38B);

  // Legacy alias kept for code that references it
  static const Color glassBorderLight = divider;
  static const Color glassBorderDark = darkDivider;
  static const Color glowTeal = teal;

  // Soft elevation shadow color
  static const Color shadow = Color(0x0F000000);

  // States
  static const Color success = Color(0xFF5B7C6A);
  static const Color error = Color(0xFFC15F52);
  static const Color amber = Color(0xFFC79A4E);
}

/// 4-pt spacing scale (iOS-like rhythm).
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20; // screen edge
  static const double xxl = 24;
}

/// Corner-radius scale — "Soft & Cozy": pillowy, generous rounding.
class AppRadius {
  AppRadius._();
  static const double sm = 10; // small chips/cells
  static const double md = 14; // controls / pills
  static const double lg = 22; // cards (cozy/pillowy)
  static const double xl = 26; // hero cards
  static const double sheet = 28; // bottom sheets
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
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
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
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCardElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
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
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
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
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
      ),
      hintStyle: TextStyle(color: hint),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  /// Inter tuned to the iOS type scale: integer sizes, restrained weights,
  /// gentle negative tracking on large titles, tight but readable leading.
  static TextTheme _buildTextTheme(Color textColor) {
    final base = TextTheme(
      // Large titles (w700, modest tracking — not w800)
      displayLarge: _style(34, FontWeight.w700, -0.5, textColor, 1.2),
      displayMedium: _style(28, FontWeight.w700, -0.4, textColor, 1.2),
      displaySmall: _style(22, FontWeight.w700, -0.4, textColor, 1.25),
      // Section / nav titles (w600)
      headlineLarge: _style(20, FontWeight.w600, -0.4, textColor, 1.3),
      headlineMedium: _style(17, FontWeight.w600, -0.4, textColor, 1.3),
      headlineSmall: _style(16, FontWeight.w600, -0.3, textColor, 1.35),
      titleLarge: _style(16, FontWeight.w600, -0.3, textColor, 1.35),
      titleMedium: _style(15, FontWeight.w600, -0.2, textColor, 1.35),
      titleSmall: _style(13, FontWeight.w600, -0.1, textColor, 1.35),
      // Body
      bodyLarge: _style(17, FontWeight.w400, -0.2, textColor, 1.4),
      bodyMedium: _style(15, FontWeight.w400, -0.2, textColor, 1.4),
      bodySmall: _style(13, FontWeight.w400, -0.1, textColor, 1.4),
      // Labels / captions
      labelLarge: _style(13, FontWeight.w600, -0.1, textColor, 1.3),
      labelMedium: _style(12, FontWeight.w600, 0.0, textColor, 1.3),
      labelSmall: _style(11, FontWeight.w600, 0.1, textColor, 1.3),
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

  /// Cozy ambient lift. Light: a soft, diffuse pillowy shadow so cards float
  /// gently off the warm background. Dark: a subtle deep shadow so pillowy
  /// cards still lift off the true-black background.
  List<BoxShadow> get softShadow => isDarkMode
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -8,
          ),
        ]
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: -6,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: -2,
          ),
        ];

  /// Surface fill for cards/chips. Optional accent [tint].
  Color glassFill([Color? tint]) {
    if (tint != null) {
      // Slightly warmer tint for the cozy, tactile feel.
      return tint.withValues(alpha: isDarkMode ? 0.18 : 0.12);
    }
    return isDarkMode ? AppColors.darkCardElevated : AppColors.card;
  }

  /// Hairline border color (theme-aware).
  Color get glassBorder => isDarkMode ? AppColors.darkDivider : AppColors.divider;

  /// Editorial card decoration: clean fill + hairline border + optional lift.
  /// (Name kept for backward-compat; no glass/blur anymore.)
  BoxDecoration glassDecoration({
    Color? tint,
    double radius = AppRadius.lg,
    bool glow = false, // kept for compat; maps to a subtle lift
    Color? glowColor,
  }) {
    final hasTint = tint != null;
    return BoxDecoration(
      color: hasTint ? glassFill(tint) : glassFill(),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: hasTint
            ? tint.withValues(alpha: 0.24)
            // Cozy cards lean on the soft shadow. Tint gives a gentle edge;
            // plain cards stay borderless for a pillowy, seamless look.
            : Colors.transparent,
        width: 1,
      ),
      boxShadow: softShadow,
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
