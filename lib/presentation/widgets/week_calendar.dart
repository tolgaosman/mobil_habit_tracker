import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/providers/language_provider.dart';

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
                  DateFormat('MMMM yyyy').format(now).tr(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.textSecondaryColor,
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
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.5),
                      child: _DayChip(
                        day: day,
                        isSelected: _isSameDay(day, provider.selectedDate),
                        isToday: _isSameDay(day, now),
                        animationDelay: index * 60,
                        onTap: () => provider.selectDate(day),
                      ),
                    ),
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
    final dayLabel = DateFormat('E').format(day).tr(context).substring(0, 1);
    final dateLabel = day.day.toString();
    final dividerColor = Theme.of(context).dividerTheme.color ?? Colors.black;
    const double offsetVal = 3.0;

    // Both selected day and current day (isToday) look pressed down/depressed
    final isPressed = isSelected || isToday;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(
          top: isPressed ? offsetVal : 0,
          left: isPressed ? offsetVal : 0,
          bottom: isPressed ? 0 : offsetVal,
          right: isPressed ? 0 : offsetVal,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 62,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.teal
                : (Theme.of(context).cardTheme.color ?? AppColors.card),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: (isToday && isSelected) ? dividerColor : (isToday ? AppColors.teal : dividerColor),
              width: 2,
            ),
            boxShadow: isPressed
                ? null
                : [
                    BoxShadow(
                      color: dividerColor,
                      offset: const Offset(offsetVal, offsetVal),
                      blurRadius: 0,
                    )
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                dayLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.black
                      : (isToday ? AppColors.teal : null),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.black
                      : (isToday ? AppColors.teal : null),
                ),
              ),
            ],
          ),
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
