import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';
import '../../data/models/habit_model.dart';
import '../../core/utils/icon_mapper.dart';
import '../../core/providers/language_provider.dart';

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
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return names[month - 1].tr(context);
  }

  bool _canToggle(DateTime date) {
    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final targetMidnight = DateTime(date.year, date.month, date.day);
    final difference = todayMidnight.difference(targetMidnight).inDays;
    return difference == 0 || difference == 1;
  }

  List<HabitModel> _getHabitsForDate(DateTime date, List<HabitModel> allHabits) {
    final targetMidnight = DateTime(date.year, date.month, date.day);
    return allHabits.where((h) {
      try {
        final created = DateTime.parse(h.createdAt);
        final createdMidnight = DateTime(created.year, created.month, created.day);
        if (createdMidnight.isAfter(targetMidnight)) return false;

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

  double _getCompletionRate(DateTime date, List<HabitModel> allHabits) {
    final habits = _getHabitsForDate(date, allHabits);
    if (habits.isEmpty) return 0.0;
    final completed = habits.where((h) => h.isCompletedOn(date)).length;
    return completed / habits.length;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final allHabits = provider.allHabits;
    final activeHabits = _getHabitsForDate(_selectedDate, allHabits);
    final completionRate = _getCompletionRate(_selectedDate, allHabits);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(context),
        _buildCompletionSummaryCard(context, completionRate, activeHabits),
        _buildCalendarSection(context, allHabits),
        const SizedBox(height: 4),
        _buildQuestsHeader(context, activeHabits.length),
        Expanded(
          child: _buildHistoryQuestList(context, activeHabits),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TASK HISTORY'.tr(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
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
      BuildContext context, double rate, List<HabitModel> activeHabits) {
    final percentage = (rate * 100).toStringAsFixed(0);
    final total = activeHabits.length;
    final completed = activeHabits.where((h) => h.isCompletedOn(_selectedDate)).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 6, 28, 6),
      padding: const EdgeInsets.all(12),
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
                  'COMPLETION RATE'.tr(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.textSecondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$percentage%',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: rate == 1.0 ? AppColors.success : AppColors.teal,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  total == 0
                      ? 'No quests active on this day.'.tr(context)
                      : '$completed of $total quests completed.'.tr(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: (rate == 1.0 ? AppColors.success : AppColors.teal).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Theme.of(context).dividerTheme.color ?? Colors.black,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                rate == 1.0 ? Icons.emoji_events_rounded : Icons.calendar_month_rounded,
                color: rate == 1.0 ? AppColors.success : AppColors.teal,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideY(begin: 0.05, end: 0, delay: 100.ms, duration: 400.ms);
  }

  Widget _buildCalendarSection(BuildContext context, List<HabitModel> allHabits) {
    final dividerColor = Theme.of(context).dividerTheme.color ?? Colors.black;

    // Calculate dates
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    
    // weekday starts at 1 (Monday) to 7 (Sunday)
    // We want Pzt (Mon) as first column. So shift is firstDayOfMonth.weekday - 1
    final emptyPrefixCells = firstDayOfMonth.weekday - 1;
    final totalDaysInMonth = lastDayOfMonth.day;
    final totalCells = emptyPrefixCells + totalDaysInMonth;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dividerColor, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: dividerColor,
            offset: const Offset(4, 4),
            blurRadius: 0,
          )
        ],
      ),
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
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
                  });
                },
              ),
              Text(
                '${_getMonthName(_focusedMonth.month, context)} ${_focusedMonth.year}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
              ),
              _buildRetroNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
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
              _WeekdayLabel('MON'),
              _WeekdayLabel('TUE'),
              _WeekdayLabel('WED'),
              _WeekdayLabel('THU'),
              _WeekdayLabel('FRI'),
              _WeekdayLabel('SAT'),
              _WeekdayLabel('SUN'),
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
              final cellDate = DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              final isToday = _isSameDay(cellDate, DateTime.now());
              final isSelected = _isSameDay(cellDate, _selectedDate);
              
              final dayHabits = _getHabitsForDate(cellDate, allHabits);
              final totalCount = dayHabits.length;
              final completedCount = dayHabits.where((h) => h.isCompletedOn(cellDate)).length;
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
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildRetroNavButton({required IconData icon, required VoidCallback onTap}) {
    final dividerColor = Theme.of(context).dividerTheme.color ?? Colors.black;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).bottomSheetTheme.backgroundColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: dividerColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: dividerColor,
              offset: const Offset(2, 2),
              blurRadius: 0,
            )
          ],
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).textTheme.titleMedium?.color),
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
    final dividerColor = Theme.of(context).dividerTheme.color ?? Colors.black;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Decide background and border colors
    Color cellBg = isDark ? AppColors.darkCard : AppColors.card;
    Color borderCol = isToday
        ? dividerColor
        : (isDark ? Colors.white10 : Colors.black.withOpacity(0.08));
    double borderWidth = isToday ? 2.0 : 1.0;

    final hasQuests = totalCount > 0;
    final allDone = hasQuests && completedCount == totalCount;

    if (isSelected) {
      cellBg = AppColors.teal.withOpacity(0.25);
      borderCol = dividerColor;
      borderWidth = 2.0;
    } else if (allDone && !isFuture) {
      // Completed all quests on this day
      cellBg = isDark ? const Color(0xFF1E3A24) : const Color(0xFFE8F5E9); // green-ish
      borderCol = AppColors.success.withOpacity(0.5);
    } else if (completedCount > 0 && !isFuture) {
      // Partially completed
      cellBg = isDark ? const Color(0xFF332A1E) : const Color(0xFFFFFDE7); // yellow-ish
      borderCol = Colors.orange.withOpacity(0.3);
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
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderCol, width: borderWidth),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$dayNum',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isFuture
                    ? context.textTertiaryColor.withOpacity(0.4)
                    : (isSelected
                        ? AppColors.teal
                        : (isToday ? Theme.of(context).colorScheme.primary : null)),
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
                      fontWeight: FontWeight.bold,
                      color: allDone
                          ? AppColors.success
                          : (completedCount > 0
                              ? Colors.orange
                              : context.textTertiaryColor),
                    ),
                  ),
                  if (allDone) ...[
                    const SizedBox(width: 1),
                    const Icon(
                      Icons.star_rounded,
                      size: 9,
                      color: Colors.orangeAccent,
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

  Widget _buildQuestsHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: [
          Text(
            'TASK LOG'.tr(context),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 400.ms);
  }

  Widget _buildHistoryQuestList(BuildContext context, List<HabitModel> habits) {
    if (habits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 40, color: context.textTertiaryColor),
            const SizedBox(height: 8),
            Text(
              'No active quests on this date.'.tr(context),
              style: TextStyle(color: context.textSecondaryColor, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms);
    }

    final canInteract = _canToggle(_selectedDate);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isCompleted = habit.isCompletedOn(_selectedDate);
        final accentColor = _hexToColor(habit.colorHex);
        final iconData = IconMapper.getIcon(habit.iconCodePoint);

        return Container(
          margin: const EdgeInsets.only(bottom: 12, right: 4),
          decoration: BoxDecoration(
            color: isCompleted
                ? accentColor.withOpacity(0.08)
                : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerTheme.color ?? Colors.black,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).dividerTheme.color ?? Colors.black,
                offset: const Offset(3, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                if (!canInteract) {
                  HapticFeedback.vibrate();
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Past history is archived! Only today and yesterday can be changed.'.tr(context),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: AppColors.textPrimary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                HapticFeedback.lightImpact();
                context.read<HabitProvider>().toggleCompletionForDate(habit, _selectedDate);
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Icon Box
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerTheme.color ?? Colors.black,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(iconData, color: accentColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    // Name
                    Expanded(
                      child: Text(
                        habit.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
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
                        color: isCompleted ? accentColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Theme.of(context).dividerTheme.color ?? Colors.black,
                          width: 2,
                        ),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.star_rounded, color: Colors.black, size: 16)
                          : (!canInteract
                              ? const Icon(Icons.close_rounded, color: AppColors.error, size: 16)
                              : null),
                    ),
                  ],
                ),
              ),
            ),
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
