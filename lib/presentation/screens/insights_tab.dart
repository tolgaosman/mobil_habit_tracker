import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/providers/language_provider.dart';
import '../../core/utils/icon_mapper.dart';
import '../../data/models/habit_model.dart';
import '../widgets/glass.dart';

class InsightsTab extends StatelessWidget {
  const InsightsTab({super.key});

  Color _hexToColor(String hex) => Color(int.parse(hex, radix: 16));

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final habits = provider.allHabits;
        final startingDate = provider.getStartingDate();

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              if (habits.isEmpty)
                _buildEmptyState(context)
              else
                ...habits.asMap().entries.map(
                      (e) => _buildHabitCard(
                        context,
                        e.value,
                        startingDate,
                        e.key * 70,
                      ),
                    ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Insights'.tr(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your progress over time'.tr(context),
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: -0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildHabitCard(
    BuildContext context,
    HabitModel habit,
    DateTime startingDate,
    int delayMs,
  ) {
    final color = _hexToColor(habit.colorHex);
    final icon = IconMapper.getIcon(habit.iconCodePoint);
    final streak = habit.currentStreak;

    return GlassCard(
      margin: const EdgeInsets.fromLTRB(24, 6, 24, 6),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon: icon, color: color, size: 44, radius: AppRadius.md),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  habit.name.tr(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (streak > 0) ...[
                const SizedBox(width: 8),
                GlassPillBadge(
                  label: '$streak ${'day streak'.tr(context)}',
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.amber,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          CompletionHeatmap(
            habits: [habit],
            startingDate: startingDate,
            color: color,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: delayMs.ms, duration: 450.ms, curve: Curves.easeOutCubic)
        .slideY(
          begin: 0.06,
          end: 0,
          delay: delayMs.ms,
          duration: 450.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insights_rounded,
                color: AppColors.teal,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No insights yet'.tr(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add habits and complete them to\nsee your progress here.'
                  .tr(context),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.textSecondaryColor,
                    height: 1.6,
                  ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}
