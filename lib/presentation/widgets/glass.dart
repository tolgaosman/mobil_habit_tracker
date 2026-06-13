import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Frosted-glass card: backdrop blur + translucent fill + light rim + layered
/// shadow. The single reusable surface for the redesigned UI.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur;

  /// Optional accent tint (e.g. category / completion color).
  final Color? tint;

  /// Whether to add a colored neon glow around the card.
  final bool glow;
  final Color? glowColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin,
    this.radius = 20,
    this.blur = 10,
    this.tint,
    this.glow = false,
    this.glowColor,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = context.glassDecoration(
      tint: tint,
      radius: radius,
      glow: glow,
      glowColor: glowColor,
    );

    Widget content = Padding(padding: padding, child: child);

    if (onTap != null || onLongPress != null) {
      content = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: (tint ?? AppColors.teal).withValues(alpha: 0.08),
          highlightColor: (tint ?? AppColors.teal).withValues(alpha: 0.04),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      ),
    );
  }
}

/// Text painted with the emerald accent gradient via [ShaderMask].
class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient? gradient;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const GradientText(
    this.text, {
    super.key,
    this.style,
    this.gradient,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final g = gradient ?? context.accentGradient;
    return ShaderMask(
      shaderCallback: (bounds) => g.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: (style ?? const TextStyle()).copyWith(color: Colors.white),
      ),
    );
  }
}

/// Circular progress ring with a soft neon glow and centered percentage.
class GlowProgressRing extends StatelessWidget {
  final double rate; // 0..1
  final double size;
  final double stroke;
  final Color? color;
  final TextStyle? labelStyle;
  final bool showLabel;

  const GlowProgressRing({
    super.key,
    required this.rate,
    this.size = 64,
    this.stroke = 7,
    this.color,
    this.labelStyle,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    final track = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: rate.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, value, __) {
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: value,
              stroke: stroke,
              color: c,
              track: track,
              glow: context.isDarkMode ? 0.55 : 0.35,
            ),
            child: showLabel
                ? Center(
                    child: Text(
                      '${(value * 100).round()}%',
                      style: labelStyle ??
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final double stroke;
  final Color color;
  final Color track;
  final double glow;

  _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.track,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * value;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    if (value <= 0) return;

    // Glow underlay.
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: glow)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawArc(rect, start, sweep, false, glowPaint);

    // Gradient progress arc.
    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: 2 * math.pi,
        transform: const GradientRotation(-math.pi / 2),
        colors: [color.withValues(alpha: 0.7), color],
      ).createShader(rect);
    canvas.drawArc(rect, start, sweep, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.stroke != stroke;
}

/// Linear progress bar with gradient fill and a faint glow.
class GlowProgressBar extends StatelessWidget {
  final double rate; // 0..1
  final double height;
  final Color? color;

  const GlowProgressBar({
    super.key,
    required this.rate,
    this.height = 8,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    final track = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: track),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: rate.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [c.withValues(alpha: 0.85), c],
                    ),
                    borderRadius: BorderRadius.circular(height),
                    boxShadow: [
                      BoxShadow(
                        color: c.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Small frosted pill used for counters and difficulty / streak badges.
class GlassPillBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const GlassPillBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.teal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon != null ? 10 : 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDarkMode ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

/// Soft gradient-bordered badge that holds a category/icon glyph.
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double radius;
  final bool glow;

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 50,
    this.radius = 15,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: context.isDarkMode ? 0.28 : 0.18),
            color.withValues(alpha: context.isDarkMode ? 0.14 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: -3,
                ),
              ]
            : null,
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}
