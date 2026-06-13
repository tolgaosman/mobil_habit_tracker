import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';
import '../../data/models/habit_model.dart';
import '../../core/utils/icon_mapper.dart';
import '../../core/providers/language_provider.dart';
import '../widgets/glass.dart';

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  late DateTime _selectedDate;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  Color _hexToColor(String hex) => Color(int.parse(hex, radix: 16));

  String _getMonthName(int month, BuildContext context) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return names[month - 1].tr(context);
  }

  bool _canToggle(DateTime date) {
    return true;
  }

  List<HabitModel> _getHabitsForDate(
      DateTime date, List<HabitModel> allHabits) {
    final targetMidnight = DateTime(date.year, date.month, date.day);
    final startingDate = _getStartingDate(allHabits);
    if (targetMidnight.isBefore(startingDate)) {
      return [];
    }

    return allHabits.where((h) {
      try {
        if (h.isCompletedOn(date)) return true;

        // Check repeatDays (1 = Monday, ..., 7 = Sunday)
        if (h.repeatDays != null && h.repeatDays!.isNotEmpty) {
          return h.repeatDays!.contains(date.weekday);
        }
        return true;
      } catch (_) {
        return true;
      }
    }).toList();
  }

  DateTime _getStartingDate(List<HabitModel> allHabits) {
    DateTime startingDate = DateTime(2026, 5, 20);
    for (final habit in allHabits) {
      try {
        final created = DateTime.parse(habit.createdAt);
        final createdDate = DateTime(created.year, created.month, created.day);
        if (createdDate.isBefore(startingDate)) {
          startingDate = createdDate;
        }
      } catch (_) {}
    }
    return startingDate;
  }

  Map<String, dynamic> _getMonthCompletionMetrics(List<HabitModel> allHabits) {
    final lastDay =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    int totalQuests = 0;
    int completedQuests = 0;

    final startingDate = _getStartingDate(allHabits);

    for (int d = 1; d <= lastDay; d++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, d);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (date.isAfter(today)) continue;
      if (date.isBefore(startingDate)) continue;

      final habits = _getHabitsForDate(date, allHabits);
      totalQuests += habits.length;
      completedQuests += habits.where((h) => h.isCompletedOn(date)).length;
    }

    final rate = totalQuests == 0 ? 0.0 : completedQuests / totalQuests;
    return {
      'rate': rate,
      'total': totalQuests,
      'completed': completedQuests,
    };
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final allHabits = provider.allHabits;
    final activeHabits = _getHabitsForDate(_selectedDate, allHabits);

    // Calculate overall metrics for the top card (focused month)
    final overallMetrics = _getMonthCompletionMetrics(allHabits);
    final overallRate = overallMetrics['rate'] as double;
    final overallTotal = overallMetrics['total'] as int;
    final overallCompleted = overallMetrics['completed'] as int;

    // Calculate today's rate
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayHabits = _getHabitsForDate(today, allHabits);
    final todayCompleted =
        todayHabits.where((h) => h.isCompletedOn(today)).length;
    final todayRate =
        todayHabits.isEmpty ? 0.0 : todayCompleted / todayHabits.length;
    final todayPercentage = (todayRate * 100).toStringAsFixed(0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopBar(context),
          _buildCompletionSummaryCard(
              context, overallRate, overallCompleted, overallTotal),
          _buildCalendarSection(context, allHabits),
          const SizedBox(height: 4),
          _buildQuestsHeader(context, activeHabits.length, todayPercentage),
          _buildHistoryQuestList(context, activeHabits),
          const SizedBox(
              height: 32), // Add bottom padding for better scroll feel
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'History'.tr(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Completion Log'.tr(context),
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

  Widget _buildCompletionSummaryCard(
      BuildContext context, double rate, int completed, int total) {
    final percentage = (rate * 100).toStringAsFixed(0);

    final isPerfect = rate >= 1.0 && total > 0;
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(24, 6, 24, 6),
      padding: const EdgeInsets.all(18),
      glow: isPerfect,
      glowColor: AppColors.tealGlow,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Completion Rate'.tr(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                GradientText(
                  '$percentage%',
                  gradient: isPerfect
                      ? const LinearGradient(
                          colors: [AppColors.success, AppColors.tealGlow])
                      : null,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  total == 0
                      ? 'No habits active this month.'.tr(context)
                      : '$completed of $total habits completed.'.tr(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GlowProgressRing(
            rate: rate,
            size: 60,
            color: isPerfect ? AppColors.success : AppColors.teal,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0, delay: 100.ms, duration: 400.ms);
  }

  Widget _buildCalendarSection(
      BuildContext context, List<HabitModel> allHabits) {
    // Calculate dates
    final firstDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth =
        DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);

    // weekday starts at 1 (Monday) to 7 (Sunday)
    // We want Pzt (Mon) as first column. So shift is firstDayOfMonth.weekday - 1
    final emptyPrefixCells = firstDayOfMonth.weekday - 1;
    final totalDaysInMonth = lastDayOfMonth.day;
    final totalCells = emptyPrefixCells + totalDaysInMonth;

    return GlassCard(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        children: [
          // Month Selector Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRetroNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                '${_getMonthName(_focusedMonth.month, context)} ${_focusedMonth.year}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              _buildRetroNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _focusedMonth = DateTime(
                        _focusedMonth.year, _focusedMonth.month + 1, 1);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Weekday Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _WeekdayLabel('Mon'),
              _WeekdayLabel('Tue'),
              _WeekdayLabel('Wed'),
              _WeekdayLabel('Thu'),
              _WeekdayLabel('Fri'),
              _WeekdayLabel('Sat'),
              _WeekdayLabel('Sun'),
            ],
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              if (index < emptyPrefixCells) {
                return const SizedBox.shrink();
              }

              final dayNum = index - emptyPrefixCells + 1;
              final cellDate =
                  DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              final isToday = _isSameDay(cellDate, DateTime.now());
              final isSelected = _isSameDay(cellDate, _selectedDate);

              final dayHabits = _getHabitsForDate(cellDate, allHabits);
              final totalCount = dayHabits.length;
              final completedCount =
                  dayHabits.where((h) => h.isCompletedOn(cellDate)).length;
              final isFuture = cellDate.isAfter(DateTime.now());

              return _buildCalendarCell(
                context: context,
                dayNum: dayNum,
                cellDate: cellDate,
                isSelected: isSelected,
                isToday: isToday,
                isFuture: isFuture,
                completedCount: completedCount,
                totalCount: totalCount,
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildRetroNavButton(
      {required IconData icon, required VoidCallback onTap}) {
    final dividerColor =
        Theme.of(context).dividerTheme.color ?? Colors.transparent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: dividerColor, width: 1),
        ),
        child: Icon(icon,
            size: 20, color: Theme.of(context).textTheme.titleMedium?.color),
      ),
    );
  }

  Widget _buildCalendarCell({
    required BuildContext context,
    required int dayNum,
    required DateTime cellDate,
    required bool isSelected,
    required bool isToday,
    required bool isFuture,
    required int completedCount,
    required int totalCount,
  }) {
    final dividerColor =
        Theme.of(context).dividerTheme.color ?? Colors.transparent;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Decide background and border colors
    Color cellBg = Theme.of(context).scaffoldBackgroundColor;
    Color borderCol = isToday ? AppColors.teal : dividerColor;
    double borderWidth = isToday ? 1.5 : 1.0;

    final hasQuests = totalCount > 0;
    final allDone = hasQuests && completedCount == totalCount;

    if (isSelected) {
      cellBg = AppColors.teal;
      borderCol = AppColors.teal;
      borderWidth = 1.0;
    } else if (allDone && !isFuture) {
      // Completed all quests on this day
      cellBg = isDark
          ? const Color(0xFF1E3A24)
          : const Color(0xFFE8F5E9); // green-ish
      borderCol = AppColors.success.withValues(alpha: 0.5);
    } else if (completedCount > 0 && !isFuture) {
      // Partially completed
      cellBg = isDark
          ? const Color(0xFF332A1E)
          : const Color(0xFFFFFDE7); // yellow-ish
      borderCol = Colors.orange.withValues(alpha: 0.3);
    }

    return GestureDetector(
      onTap: isFuture
          ? null
          : () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedDate = cellDate;
              });
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          gradient: isSelected ? context.accentGradient : null,
          color: isSelected ? null : cellBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderCol, width: borderWidth),
          boxShadow: isSelected
              ? context.glowShadow(AppColors.tealGlow, strength: 0.6)
              : (allDone && !isFuture
                  ? [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.25),
                        blurRadius: 8,
                        spreadRadius: -3,
                      ),
                    ]
                  : null),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNum',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isFuture
                    ? context.textTertiaryColor.withValues(alpha: 0.4)
                    : (isSelected
                        ? Colors.white
                        : (isToday
                            ? Theme.of(context).colorScheme.primary
                            : null)),
              ),
            ),
            if (hasQuests && !isFuture) ...[
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$completedCount/$totalCount',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : (allDone
                              ? AppColors.success
                              : (completedCount > 0
                                  ? Colors.orange
                                  : context.textTertiaryColor)),
                    ),
                  ),
                  if (allDone) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Icons.check_circle_rounded,
                      size: 9,
                      color: isSelected ? Colors.white : AppColors.success,
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsHeader(
      BuildContext context, int count, String todayPercentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            'Habits'.tr(context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          GlassPillBadge(label: '$count'),
          const Spacer(),
          Text(
            '${'Today: '.tr(context)}$todayPercentage%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: todayPercentage == '100'
                      ? AppColors.success
                      : AppColors.teal,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryQuestList(BuildContext context, List<HabitModel> habits) {
    if (habits.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_toggle_off_rounded,
                  size: 40, color: context.textTertiaryColor),
              const SizedBox(height: 8),
              Text(
                'No habits on this date.'.tr(context),
                style: TextStyle(
                    color: context.textSecondaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 400.ms);
    }

    final canInteract = _canToggle(_selectedDate);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isCompleted = habit.isCompletedOn(_selectedDate);
        final accentColor = _hexToColor(habit.colorHex);
        final iconData = IconMapper.getIcon(habit.iconCodePoint);

        return GlassCard(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          radius: 16,
          tint: isCompleted ? accentColor : null,
          glow: isCompleted,
          glowColor: accentColor,
          onTap: () {
            HapticFeedback.lightImpact();
            context
                .read<HabitProvider>()
                .toggleCompletionForDate(habit, _selectedDate);
          },
          child: Row(
            children: [
              IconBadge(
                icon: iconData,
                color: accentColor,
                size: 42,
                radius: 12,
                glow: isCompleted,
              ),
              const SizedBox(width: 12),
              // Name
              Expanded(
                child: Text(
                  habit.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? context.textSecondaryColor : null,
                        decorationColor: context.textTertiaryColor,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              // Status Checkbox
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: isCompleted
                      ? LinearGradient(
                          colors: [
                            accentColor,
                            accentColor.withValues(alpha: 0.75)
                          ],
                        )
                      : null,
                  color: isCompleted ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: isCompleted
                        ? accentColor
                        : (Theme.of(context).dividerTheme.color ?? Colors.grey),
                    width: 2,
                  ),
                  boxShadow: isCompleted
                      ? [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                child: isCompleted
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 16)
                    : (!canInteract
                        ? const Icon(Icons.close_rounded,
                            color: AppColors.error, size: 16)
                        : null),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;
  const _WeekdayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label.tr(context),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 9,
                color: context.textTertiaryColor,
              ),
        ),
      ),
    );
  }
}
