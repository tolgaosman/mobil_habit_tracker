import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final total = provider.habits.length;
        final completed = provider.completedToday;
        final rate = provider.completionRate;

        return Container(
          margin: const EdgeInsets.fromLTRB(24, 4, 24, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider, width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completed / $total completed',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _AnimatedProgressBar(rate: rate),
                    const SizedBox(height: 8),
                    Text(
                      total == 0
                          ? 'Add your first habit!'
                          : rate == 1.0
                              ? '🎉 All done for today!'
                              : '${(rate * 100).toStringAsFixed(0)}% complete',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: rate == 1.0
                                ? AppColors.teal
                                : AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              _CircularProgress(rate: rate),
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

class _AnimatedProgressBar extends StatelessWidget {
  final double rate;
  const _AnimatedProgressBar({required this.rate});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: rate),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
        builder: (_, value, __) {
          return LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: AppColors.divider,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.teal),
          );
        },
      ),
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final double rate;
  const _CircularProgress({required this.rate});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: rate),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (_, value, __) {
        return SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 5,
                backgroundColor: AppColors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
