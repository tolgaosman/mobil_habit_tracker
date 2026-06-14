import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Faint, fixed graph-paper grid that sits BEHIND content — a calm editorial
/// texture (hairline squares), not a busy icon scatter. Render-cheap (single
/// CustomPainter, never repaints on scroll). Taps pass through via IgnorePointer.
///
/// Drop into any Scaffold-body Stack as the first child:
///   Stack(children: [const BackgroundMotif(), <content>])
class BackgroundMotif extends StatelessWidget {
  const BackgroundMotif({
    super.key,
    this.iconCount = 12,
    this.seed = 7,
  });

  /// Kept for backward-compat with existing call sites; no longer used.
  final int iconCount;

  /// Kept for backward-compat with existing call sites; no longer used.
  final int seed;

  /// Grid cell size in logical pixels.
  static const double _cell = 28.0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    final base = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    // A whisper: hairline lines at a very low alpha so the grid melts into the surface.
    final color = base.withValues(alpha: isDark ? 0.05 : 0.04);

    return Positioned.fill(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _GridPainter(color: color, cell: _cell),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.color, required this.cell});

  final Color color;
  final double cell;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Vertical hairlines.
    for (double x = 0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal hairlines.
    for (double y = 0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.color != color || old.cell != cell;
}
