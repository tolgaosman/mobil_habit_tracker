import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/utils/icon_mapper.dart';
import '../../data/models/habit_model.dart';
import '../screens/add_habit_screen.dart';

class HabitList extends StatelessWidget {
  const HabitList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, provider, _) {
        final habits = provider.habits;

        if (habits.isEmpty) {
          return _EmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 120),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            return HabitCard(
              habit: habits[index],
              animationDelay: index * 80,
            );
          },
        );
      },
    );
  }
}

class HabitCard extends StatefulWidget {
  final HabitModel habit;
  final int animationDelay;

  const HabitCard({
    super.key,
    required this.habit,
    this.animationDelay = 0,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_checkController);
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) => Color(int.parse(hex, radix: 16));

  bool _canToggle(DateTime selectedDate) {
    final now = DateTime.now();
    final selectedMidnight = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final todayMidnight = DateTime(now.year, now.month, now.day);
    final difference = todayMidnight.difference(selectedMidnight).inDays;
    return difference == 0 || difference == 1;
  }

  void _toggle(BuildContext context) {
    final provider = context.read<HabitProvider>();
    if (!_canToggle(provider.selectedDate)) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Sadece bugün ve dün için işaretleme yapabilirsiniz.',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.textPrimary,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    HapticFeedback.lightImpact();
    _checkController.forward(from: 0);
    provider.toggleCompletion(widget.habit);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final isCompleted =
        widget.habit.isCompletedOn(provider.selectedDate);
    final accentColor = _hexToColor(widget.habit.colorHex);
    final iconData = IconMapper.getIcon(widget.habit.iconCodePoint);
    final streak = widget.habit.currentStreak;
    final canInteract = _canToggle(provider.selectedDate);

    return Dismissible(
      key: Key(widget.habit.id),
      direction: DismissDirection.endToStart,
      background: _buildDeleteBackground(),
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          context.read<HabitProvider>().deleteHabit(widget.habit.id),
      child: GestureDetector(
        onLongPress: () => _showOptions(context),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16, right: 4), // extra margin for offset shadow
          decoration: BoxDecoration(
            color: isCompleted
                ? accentColor.withOpacity(0.12)
                : Theme.of(context).cardTheme.color,
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
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _toggle(context), // allow tapping anywhere on card to toggle is standard retro convenience!
              splashColor: accentColor.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).dividerTheme.color ?? Colors.black,
                          width: 2,
                        ),
                      ),
                      child: Icon(iconData, color: accentColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    // Name + streak
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.habit.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: isCompleted
                                      ? AppColors.textSecondary
                                      : null,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppColors.textTertiary,
                                ),
                          ),
                          if (streak > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.local_fire_department_rounded,
                                  color: Color(0xFFFF9F43),
                                  size: 14,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'COMBO: $streak',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFFFF9F43),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Completion toggle
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: GestureDetector(
                        onTap: () => _toggle(context),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(6),
                            color: isCompleted
                                ? (canInteract ? accentColor : accentColor.withOpacity(0.4))
                                : Colors.transparent,
                            border: Border.all(
                              color: Theme.of(context).dividerTheme.color ?? Colors.black,
                              width: 2.5,
                            ),
                          ),
                          child: isCompleted
                              ? Icon(
                                  Icons.star_rounded,
                                  color: canInteract ? Colors.black : Colors.black54,
                                  size: 18,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: widget.animationDelay),
          duration: 400.ms,
          curve: Curves.easeOut,
        )
        .slideX(
          begin: 0.05,
          end: 0,
          delay: Duration(milliseconds: widget.animationDelay),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildDeleteBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.delete_outline_rounded,
              color: AppColors.error, size: 26),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Delete Habit'),
        content: Text(
          'Are you sure you want to delete "${widget.habit.name}"? This cannot be undone.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(habit: widget.habit),
    );
  }
}

class _OptionsSheet extends StatelessWidget {
  final HabitModel habit;
  const _OptionsSheet({required this.habit});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            habit.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          _OptionTile(
            icon: Icons.edit_outlined,
            label: 'Edit Habit',
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => AddHabitSheet(
                  isEditing: true,
                  habitId: habit.id,
                  initialName: habit.name,
                  initialIconCodePoint: habit.iconCodePoint,
                  initialColorHex: habit.colorHex,
                  initialRepeatDays: habit.repeatDays,
                ),
              );
            },
          ),
          _OptionTile(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Habit',
            color: AppColors.error,
            onTap: () {
              Navigator.pop(context);
              context.read<HabitProvider>().deleteHabit(habit.id);
            },
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: c, size: 20),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: c,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: AppColors.teal,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No habits yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to start\nbuilding your first habit.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.9, 0.9), duration: 500.ms);
  }
}
