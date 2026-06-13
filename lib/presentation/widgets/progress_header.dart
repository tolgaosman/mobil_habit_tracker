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
          padding: const EdgeInsets.all(20),
          glow: allDone,
          glowColor: AppColors.tealGlow,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            "Today's Progress".tr(context),
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlassPillBadge(label: '$completed/$total'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    GlowProgressBar(rate: rate),
                    const SizedBox(height: 10),
                    Text(
                      total == 0
                          ? 'Add your first habit below'.tr(context)
                          : allDone
                              ? 'All done for today!'.tr(context)
                              : '${'Progress: '.tr(context)}${(rate * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: allDone
                                ? AppColors.success
                                : context.textSecondaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              GlowProgressRing(rate: rate, size: 64),
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
