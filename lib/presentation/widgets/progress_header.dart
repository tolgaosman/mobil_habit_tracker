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
          margin: const EdgeInsets.fromLTRB(24, 4, 28, 8), // right: 28 to leave room for offset shadow
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? Colors.black,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).dividerTheme.color ?? Colors.black,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUEST: $completed / $total DONE',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 10),
                    _AnimatedProgressBar(rate: rate),
                    const SizedBox(height: 8),
                    Text(
                      total == 0
                          ? 'Press NEW QUEST below!'
                          : rate == 1.0
                              ? '🏆 QUEST COMPLETED!'
                              : 'LEVEL PROGRESS: ${(rate * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: rate == 1.0
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
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
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerTheme.color ?? Colors.black,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: rate),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder: (_, value, __) {
            return LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.teal),
            );
          },
        ),
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
                strokeWidth: 6,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.teal),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
        );
      },
    );
  }
}
