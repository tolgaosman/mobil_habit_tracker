import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/providers/language_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/utils/icon_mapper.dart';
import '../../data/models/habit_model.dart';
import '../screens/add_habit_screen.dart';
import 'glass.dart';

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
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
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
    return true;
  }

  void _toggle(BuildContext context) {
    final provider = context.read<HabitProvider>();
    HapticFeedback.lightImpact();
    _checkController.forward(from: 0);
    provider.toggleCompletion(widget.habit);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitProvider>();
    final isCompleted = widget.habit.isCompletedOn(provider.selectedDate);
    final accentColor = _hexToColor(widget.habit.colorHex);
    final iconData = IconMapper.getIcon(widget.habit.iconCodePoint);
    final streak = widget.habit.currentStreak;
    final canInteract = _canToggle(provider.selectedDate);

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      radius: 18,
      tint: isCompleted ? accentColor : null,
      glow: isCompleted,
      glowColor: accentColor,
      onTap: () => _toggle(context),
      onLongPress: () => _showOptions(context),
      child: Row(
        children: [
          // Icon badge
          IconBadge(
            icon: iconData,
            color: accentColor,
            size: 50,
            radius: 14,
            glow: isCompleted,
          ),
          const SizedBox(width: 14),
          // Name + streak
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.habit.name.tr(context),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isCompleted ? context.textSecondaryColor : null,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        decorationColor: context.textTertiaryColor,
                      ),
                ),
                if (streak > 0) ...[
                  const SizedBox(height: 6),
                  GlassPillBadge(
                    label: '$streak ${'day streak'.tr(context)}',
                    icon: Icons.local_fire_department_rounded,
                    color: AppColors.amber,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Completion toggle
          ScaleTransition(
            scale: _scaleAnimation,
            child: CompletionCheck(
              completed: isCompleted,
              color: canInteract
                  ? accentColor
                  : accentColor.withValues(alpha: 0.4),
              size: 30,
              onTap: () => _toggle(context),
            ),
          ),
        ],
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
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                color: AppColors.textTertiary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            habit.name.tr(context),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 20),
          _OptionTile(
            icon: Icons.edit_outlined,
            label: 'Edit Habit'.tr(context),
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
            label: 'Delete Habit'.tr(context),
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
    final c = color ?? Theme.of(context).textTheme.titleSmall?.color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.1),
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
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_task_rounded,
              color: AppColors.teal,
              size: 38,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No habits yet'.tr(context),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to start\nbuilding your first habit.'
                .tr(context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.textSecondaryColor,
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
