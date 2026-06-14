import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/habit_model.dart';

/// Editorial surface card: clean opaque fill + hairline border + subtle lift.
/// (Class name kept as `GlassCard` so existing imports/usages don't break,
/// but there is no blur/glass anymore — this is the airy editorial card.)
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final double blur; // ignored; kept for API compat

  /// Optional accent tint (e.g. category / completion color).
  final Color? tint;

  /// Whether to lift the card with a subtle shadow.
  final bool glow; // maps to "elevated" in editorial
  final Color? glowColor; // ignored; kept for API compat
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.margin,
    this.radius = AppRadius.lg,
    this.blur = 0,
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
          splashColor: (tint ?? AppColors.teal).withValues(alpha: 0.06),
          highlightColor: (tint ?? AppColors.teal).withValues(alpha: 0.03),
          child: content,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}

/// Emphasis heading. In editorial it's just clean, tight, weighted text — the
/// gradient is opt-in (defaults to a flat accent color, not a gradient).
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
    final baseStyle = (style ?? const TextStyle());
    if (gradient == null) {
      // Editorial default: flat accent-colored emphasis text.
      return Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: baseStyle.copyWith(color: AppColors.teal),
      );
    }
    return ShaderMask(
      shaderCallback: (bounds) => gradient!.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: baseStyle.copyWith(color: Colors.white),
      ),
    );
  }
}

/// Clean circular progress ring with centered percentage (no glow).
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
    this.stroke = 6,
    this.color,
    this.labelStyle,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    final track = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: rate.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 750),
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
            ),
            child: showLabel
                ? Center(
                    child: Text(
                      '${(value * 100).round()}%',
                      style: labelStyle ??
                          Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
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

  _RingPainter({
    required this.value,
    required this.stroke,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const start = -math.pi / 2;

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, 0, 2 * math.pi, false, trackPaint);

    if (value <= 0) return;

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, start, 2 * math.pi * value, false, arcPaint);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.stroke != stroke;
}

/// Clean linear progress bar (rounded, flat fill — no glow).
class GlowProgressBar extends StatelessWidget {
  final double rate; // 0..1
  final double height;
  final Color? color;

  const GlowProgressBar({
    super.key,
    required this.rate,
    this.height = 6,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.teal;
    final track = context.isDarkMode
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.05);

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: Stack(
        children: [
          Container(height: height, color: track),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: rate.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(height),
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

/// Small calm pill for counters and difficulty / streak badges.
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
      padding:
          EdgeInsets.symmetric(horizontal: icon != null ? 9 : 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDarkMode ? 0.16 : 0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.5, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

/// Soft pastel tonal badge holding a category/icon glyph (no gradient/glow).
class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double radius;
  final bool glow; // ignored; kept for API compat

  const IconBadge({
    super.key,
    required this.icon,
    required this.color,
    this.size = 48,
    this.radius = AppRadius.md,
    this.glow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: context.isDarkMode ? 0.24 : 0.15),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: color, size: size * 0.46),
    );
  }
}

/// Shared circular completion toggle (filled accent when done, hairline ring
/// when not). One definition so every list row reads identically.
class CompletionCheck extends StatelessWidget {
  final bool completed;
  final Color color;
  final double size;
  final VoidCallback? onTap;

  const CompletionCheck({
    super.key,
    required this.completed,
    this.color = AppColors.teal,
    this.size = 28,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final box = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? color : Colors.transparent,
        border: Border.all(
          color: completed ? color : context.glassBorder,
          width: 1.5,
        ),
      ),
      child: completed
          ? Icon(Icons.check_rounded, color: Colors.white, size: size * 0.62)
          : null,
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, child: box);
  }
}

/// GitHub-style weekly contribution grid for habit completion.
/// Computes a per-day completion ratio from [habits] and paints each day cell
/// with a stepped sage tone. Pure presentation — reads existing model data.
class CompletionHeatmap extends StatelessWidget {
  final List<HabitModel> habits;
  final DateTime startingDate;

  /// Number of weeks (columns) to show.
  final int weeks;

  /// Fill color for completed cells (defaults to the sage brand accent).
  final Color? color;

  const CompletionHeatmap({
    super.key,
    required this.habits,
    required this.startingDate,
    this.weeks = 12,
    this.color,
  });

  /// Completion ratio for a given day: completed / scheduled (0..1, -1 = none).
  double _ratioFor(DateTime date) {
    final dayMidnight = DateTime(date.year, date.month, date.day);
    final startMidnight =
        DateTime(startingDate.year, startingDate.month, startingDate.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (dayMidnight.isBefore(startMidnight) || dayMidnight.isAfter(today)) {
      return -1;
    }

    int scheduled = 0;
    int completed = 0;
    for (final h in habits) {
      bool isScheduled;
      if (h.repeatDays != null && h.repeatDays!.isNotEmpty) {
        isScheduled = h.repeatDays!.contains(date.weekday);
      } else {
        isScheduled = true;
      }
      final done = h.isCompletedOn(date);
      if (isScheduled || done) {
        scheduled++;
        if (done) completed++;
      }
    }
    if (scheduled == 0) return -1;
    return completed / scheduled;
  }

  Color _toneFor(BuildContext context, double ratio) {
    final isDark = context.isDarkMode;
    if (ratio < 0) {
      // No scheduled habits / out of range: empty cell.
      return isDark
          ? Colors.white.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.045);
    }
    if (ratio == 0) {
      return isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.07);
    }
    // Stepped tone by completion ratio, in the habit's accent color.
    final double alpha;
    if (ratio < 0.34) {
      alpha = 0.28;
    } else if (ratio < 0.67) {
      alpha = 0.5;
    } else if (ratio < 1.0) {
      alpha = 0.72;
    } else {
      alpha = 1.0;
    }
    return (color ?? AppColors.teal).withValues(alpha: alpha);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // End at the Sunday of the current week so columns align to weeks (Mon-Sun).
    final endOfWeek = today.add(Duration(days: 7 - today.weekday));
    final totalDays = weeks * 7;
    final firstDay = endOfWeek.subtract(Duration(days: totalDays - 1));

    const gap = 3.0;
    // Cells stretch horizontally to fill the card (same width as the calendar);
    // height stays short & fixed so vertical size is unchanged.
    const cellHeight = 11.0;

    // Build columns (weeks); columns share the full width equally via Expanded.
    final columns = <Widget>[];
    for (int w = 0; w < weeks; w++) {
      final cells = <Widget>[];
      for (int d = 0; d < 7; d++) {
        final date = firstDay.add(Duration(days: w * 7 + d));
        final ratio = _ratioFor(date);
        cells.add(
          Container(
            height: cellHeight,
            margin: EdgeInsets.only(bottom: d == 6 ? 0 : gap),
            decoration: BoxDecoration(
              color: _toneFor(context, ratio),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }
      columns.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: w == weeks - 1 ? 0 : gap),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: cells,
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns,
    );
  }
}
