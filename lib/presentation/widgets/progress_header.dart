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

        return GlassCard(
          margin: const EdgeInsets.fromLTRB(24, 4, 24, 8),
          padding: const EdgeInsets.all(24),
          radius: AppRadius.xl,
          glow: allDone,
          glowColor: AppColors.tealGlow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big hero ring — the cozy centerpiece.
              GlowProgressRing(
                rate: rate,
                size: 132,
                stroke: 12,
                labelStyle:
                    Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: allDone
                              ? AppColors.success
                              : Theme.of(context).textTheme.displayMedium?.color,
                        ),
              ),
              const SizedBox(height: 18),
              Text(
                total == 0
                    ? 'Add your first habit below'.tr(context)
                    : allDone
                        ? 'All done for today!'.tr(context)
                        : '$completed ${'of'.tr(context)} $total ${'habits done'.tr(context)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: allDone
                          ? AppColors.success
                          : context.textSecondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              GlowProgressBar(rate: rate),
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
