import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/routine_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../data/models/routine_task_model.dart';
import 'profile_screen.dart';
import '../widgets/glass.dart';
import 'dart:io';

class RoutineTab extends StatelessWidget {
  const RoutineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutineProvider>();
    final routines = provider.routines;
    final totalCount = routines.length;
    final completedCount = routines.where((t) => t.isCompleted).length;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(context),
        _buildProgressCard(context, completedCount, totalCount, progress),
        const SizedBox(height: 12),
        _buildSectionHeader(context, totalCount),
        Expanded(
          child: totalCount == 0
              ? _buildEmptyState(context)
              : _buildRoutineList(context, routines),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day Planner',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: context.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                'Daily Routine',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.8,
                    ),
              ),
            ],
          ),
          const Spacer(),
          _buildThemeToggleButton(context),
          const SizedBox(width: 8),
          _buildAvatarButton(context, user),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms, curve: Curves.easeOut)
        .slideY(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  Widget _buildThemeToggleButton(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return IconButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        themeProvider.toggleTheme();
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) =>
            ScaleTransition(scale: anim, child: child),
        child: Icon(
          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDark),
          color: isDark ? AppColors.teal : AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildAvatarButton(BuildContext context, dynamic user) {
    final hasImage =
        user?.profileImagePath != null && user!.profileImagePath!.isNotEmpty;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: context.glassBorder, width: 1),
        ),
        child: ClipOval(
          child: hasImage
              ? Image.file(
                  File(user.profileImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultAvatar(),
                )
              : _buildDefaultAvatar(),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.teal.withValues(alpha: 0.14),
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.teal,
        size: 20,
      ),
    );
  }

  Widget _buildProgressCard(
      BuildContext context, int completed, int total, double progress) {
    final allDone = total > 0 && progress >= 1.0;
    return GlassCard(
      margin: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      padding: const EdgeInsets.all(20),
      glow: allDone,
      glowColor: AppColors.tealGlow,
      child: Column(
        children: [
          Row(
            children: [
              GlowProgressRing(rate: progress, size: 58, stroke: 6),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$completed of $total done',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).toInt()}% complete',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: context.textSecondaryColor,
                          ),
                    ),
                  ],
                ),
              ),
              if (total > 0)
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    context.read<RoutineProvider>().resetAllCompletions();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    foregroundColor: context.textSecondaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          GlowProgressBar(rate: progress),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 150.ms, duration: 450.ms)
        .slideY(begin: 0.1, end: 0, delay: 150.ms, duration: 450.ms);
  }

  Widget _buildSectionHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          Text(
            'Timeline',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.textSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          GlassPillBadge(label: '$count'),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.teal.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 38,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No routines pre-planned',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pre-plan your day and get notified when your tasks are scheduled.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildRoutineList(BuildContext context, List<RoutineTask> routines) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
      itemCount: routines.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = routines[index];
        return _RoutineCard(task: task);
      },
    );
  }
}

class _RoutineCard extends StatefulWidget {
  final RoutineTask task;

  const _RoutineCard({required this.task});

  @override
  State<_RoutineCard> createState() => _RoutineCardState();
}

class _RoutineCardState extends State<_RoutineCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    if (widget.task.isCompleted) {
      _checkController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _RoutineCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isCompleted != oldWidget.task.isCompleted) {
      if (widget.task.isCompleted) {
        _checkController.forward();
      } else {
        _checkController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  void _toggle(BuildContext context) {
    HapticFeedback.lightImpact();
    if (!widget.task.isCompleted) {
      _checkController.forward(from: 0);
    } else {
      _checkController.reverse(from: 1);
    }
    context.read<RoutineProvider>().toggleCompletion(widget.task);
  }

  void _showOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded,
                  color: AppColors.textSecondary),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddRoutineSheet(
                    isEditing: true,
                    task: widget.task,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_rounded, color: AppColors.error),
              title: const Text('Delete Task',
                  style: TextStyle(color: AppColors.error)),
              onTap: () {
                Navigator.pop(context);
                context.read<RoutineProvider>().deleteRoutine(widget.task.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.teal;
    final isCompleted = widget.task.isCompleted;
    final iconColor = isCompleted ? AppColors.teal : AppColors.violet;

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
          IconBadge(
            icon: Icons.alarm_rounded,
            color: iconColor,
            size: 46,
            radius: 13,
            glow: isCompleted,
          ),
          const SizedBox(width: 14),
          // Name + scheduled time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.task.title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted ? context.textSecondaryColor : null,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: context.textSecondaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.task.time,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: context.textSecondaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Completion toggle
          GestureDetector(
            onTap: () => _toggle(context),
            child: ScaleTransition(
              scale: Tween(begin: 1.0, end: 0.9).animate(
                CurvedAnimation(
                  parent: _checkController,
                  curve: Curves.easeOut,
                ),
              ),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? accentColor
                        : (Theme.of(context).dividerTheme.color ?? Colors.grey),
                    width: 1.5,
                  ),
                  color: isCompleted ? accentColor : Colors.transparent,
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddRoutineSheet extends StatefulWidget {
  final bool isEditing;
  final RoutineTask? task;

  const AddRoutineSheet({
    super.key,
    this.isEditing = false,
    this.task,
  });

  @override
  State<AddRoutineSheet> createState() => _AddRoutineSheetState();
}

class _AddRoutineSheetState extends State<AddRoutineSheet> {
  final _titleController = TextEditingController();
  final _focusNode = FocusNode();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.task != null) {
      _titleController.text = widget.task!.title;
      final parts = widget.task!.time.split(':');
      final hour = int.tryParse(parts[0]) ?? 9;
      final minute = int.tryParse(parts[1]) ?? 0;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.teal,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    setState(() => _isLoading = true);

    final hourStr = _selectedTime.hour.toString().padLeft(2, '0');
    final minStr = _selectedTime.minute.toString().padLeft(2, '0');
    final timeStr = "$hourStr:$minStr";

    final provider = context.read<RoutineProvider>();

    if (widget.isEditing && widget.task != null) {
      final updated = widget.task!.copyWith(
        title: title,
        time: timeStr,
      );
      await provider.updateRoutine(updated);
    } else {
      await provider.addRoutine(title, timeStr);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPadding),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            _buildTitle(),
            const SizedBox(height: 24),
            _buildNameField(),
            const SizedBox(height: 24),
            _buildTimeSection(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.textTertiary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        widget.isEditing ? 'Edit Task' : 'Pre-plan Task',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Title',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _titleController,
          focusNode: _focusNode,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'e.g. Morning Meditation',
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.violet.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.alarm_rounded,
                      color: AppColors.violet,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(60)],
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduled Time',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _selectTime,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Theme.of(context).dividerTheme.color ?? Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: context.textSecondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _selectedTime.format(context),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                const Text(
                  'Change',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final title = _titleController.text.trim();
    final isEnabled = title.isNotEmpty && !_isLoading;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isEnabled ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Theme.of(context).dividerTheme.color,
          disabledForegroundColor: context.textTertiaryColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                widget.isEditing ? 'Save Changes' : 'Schedule Notification',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}
