import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/language_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';
import 'glass.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final total = provider.habits.length;
        final completed = provider.completedToday;
        final rate = provider.completionRate;
        final allDone = total > 0 && rate >= 1.0;

        final accent = allDone ? AppColors.success : null;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: big percentage + subtitle, reads instantly.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(rate * 100).round()}%',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                                color: accent,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          total == 0
                              ? 'Add your first habit below'.tr(context)
                              : allDone
                                  ? 'All done for today!'.tr(context)
                                  : '$completed ${'of'.tr(context)} $total ${'habits done'.tr(context)}',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: accent ?? context.textSecondaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right: compact ring — glanceable companion (no label, number is on the left).
                  GlowProgressRing(
                    rate: rate,
                    size: 56,
                    stroke: 6,
                    showLabel: false,
                    color: accent,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GlowProgressBar(rate: rate, height: 8, color: accent),
            ],
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms, duration: 500.ms)
            .slideY(begin: 0.1, end: 0, delay: 200.ms, duration: 500.ms);
      },
    );
  }
}
