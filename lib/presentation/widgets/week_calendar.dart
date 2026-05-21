import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Get start of week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month + Year label
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  DateFormat('MMMM yyyy').format(now),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              // Day chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: days.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  return _DayChip(
                    day: day,
                    isSelected: _isSameDay(day, provider.selectedDate),
                    isToday: _isSameDay(day, now),
                    animationDelay: index * 60,
                    onTap: () => provider.selectDate(day),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DayChip extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final int animationDelay;
  final VoidCallback onTap;

  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.animationDelay,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('E').format(day).substring(0, 1);
    final dateLabel = day.day.toString();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: 40,
        height: 68,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.teal
              : isToday
                  ? AppColors.teal.withOpacity(0.1)
                  : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.teal.withOpacity(0.5), width: 1)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.teal.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: isSelected
                    ? AppColors.background
                    : AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              dateLabel,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? AppColors.background
                    : isToday
                        ? AppColors.teal
                        : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: animationDelay),
          duration: 400.ms,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.3,
          end: 0,
          delay: Duration(milliseconds: animationDelay),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}
