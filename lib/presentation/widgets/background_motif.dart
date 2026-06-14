import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Faint, fixed, deterministic scatter of small themed icons that sits BEHIND
/// content. Render-cheap (single CustomPainter, never repaints on scroll).
/// Taps pass through via IgnorePointer.
///
/// Drop into any Scaffold-body Stack as the first child:
///   Stack(children: [const BackgroundMotif(), <content>])
class BackgroundMotif extends StatelessWidget {
  const BackgroundMotif({
    super.key,
    this.iconCount = 20,
    this.seed = 7,
  });

  /// Number of glyphs to scatter (keep sparse: 14-22).
  final int iconCount;

  /// Fixed seed -> stable positions across rebuilds.
  final int seed;

  // Themed motif glyphs (round-robin picked).
  static const List<IconData> _motif = <IconData>[
    Icons.eco,
    Icons.water_drop_rounded,
    Icons.auto_awesome,
    Icons.fitness_center_rounded,
    Icons.menu_book_rounded,
    Icons.self_improvement,
    Icons.spa,
    Icons.local_fire_department_rounded,
    Icons.bedtime_rounded,
    Icons.favorite_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final base = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    // A whisper: text color at a very low alpha so it melts into the surface.
    final color = base.withValues(alpha: isDark ? 0.05 : 0.04);

    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _IconScatterPainter(
              icons: _motif,
              iconCount: iconCount,
              seed: seed,
              color: color,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _IconScatterPainter extends CustomPainter {
  _IconScatterPainter({
    required this.icons,
    required this.iconCount,
    required this.seed,
    required this.color,
  });

  final List<IconData> icons;
  final int iconCount;
  final int seed;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(seed);
    final painter = TextPainter(textDirection: TextDirection.ltr);

    // Use a grid to ensure even distribution across the screen
    final cols = math.max(1, math.sqrt(iconCount).ceil());
    final rows = math.max(1, (iconCount / cols).ceil());
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    for (var i = 0; i < iconCount; i++) {
      final icon = icons[i % icons.length];
      final fontSize = 18.0 + rng.nextDouble() * 16.0; // 18..34
      
      final c = i % cols;
      final r = i ~/ cols;

      // Random position within the grid cell
      final dx = c * cellWidth + rng.nextDouble() * cellWidth;
      final dy = r * cellHeight + rng.nextDouble() * cellHeight;
      final angle = (rng.nextDouble() - 0.5) * 0.6; // ~ +/-0.3 rad slight tilt

      painter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: fontSize,
          color: color,
          height: 1.0,
        ),
      );
      painter.layout();

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(angle);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _IconScatterPainter old) =>
      old.color != color ||
      old.iconCount != iconCount ||
      old.seed != seed;
}
