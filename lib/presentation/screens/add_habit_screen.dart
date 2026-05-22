import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/providers/language_provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/habit_provider.dart';
import '../../core/utils/icon_mapper.dart';

class AddHabitSheet extends StatefulWidget {
  final bool isEditing;
  final String? habitId;
  final String? initialName;
  final String? initialIconCodePoint;
  final String? initialColorHex;
  final List<int>? initialRepeatDays;

  const AddHabitSheet({
    super.key,
    this.isEditing = false,
    this.habitId,
    this.initialName,
    this.initialIconCodePoint,
    this.initialColorHex,
    this.initialRepeatDays,
  });

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _nameController = TextEditingController();
  final _focusNode = FocusNode();
  late String _selectedIconCodePoint;
  late String _selectedColorHex;
  late List<int> _selectedDays;
  bool _notificationsEnabled = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;

  final List<Map<String, dynamic>> _iconOptions = [
    {'label': 'Nutrition', 'codePoint': 'nutrition', 'icon': Icons.restaurant_rounded},
    {'label': 'Water', 'codePoint': 'water', 'icon': Icons.water_drop_rounded},
    {'label': 'Exercise', 'codePoint': 'exercise', 'icon': Icons.fitness_center_rounded},
    {'label': 'Technology', 'codePoint': 'technology', 'icon': Icons.computer_rounded},
    {'label': 'Education', 'codePoint': 'education', 'icon': Icons.school_rounded},
    {'label': 'Other', 'codePoint': 'other', 'icon': Icons.category_rounded},
  ];

  static const Map<String, String> _categoryColors = {
    'nutrition': 'FFFF6B6B',   // Coral/Red
    'water': 'FF54A0FF',       // Blue
    'exercise': 'FFFF9F43',    // Orange
    'technology': 'FF341F97',  // Indigo
    'education': 'FF9B6DFF',   // Violet
    'other': 'FF00D2D3',       // Teal
  };

  @override
  void initState() {
    super.initState();
    final initialCode = widget.initialIconCodePoint;
    String mappedCode = 'other';
    if (initialCode != null) {
      if (initialCode == 'run' || initialCode == 'gym' || initialCode == 'exercise') {
        mappedCode = 'exercise';
      } else if (initialCode == 'water') {
        mappedCode = 'water';
      } else if (initialCode == 'book' || initialCode == 'code' || initialCode == 'education') {
        mappedCode = 'education';
      } else if (initialCode == 'food' || initialCode == 'nutrition') {
        mappedCode = 'nutrition';
      } else if (initialCode == 'work' || initialCode == 'technology') {
        mappedCode = 'technology';
      } else {
        mappedCode = 'other';
      }
    } else {
      mappedCode = _iconOptions.first['codePoint'] as String;
    }
    _selectedIconCodePoint = mappedCode;
    _selectedColorHex = widget.initialColorHex ??
        _categoryColors[_selectedIconCodePoint] ??
        _categoryColors.values.first;
    _selectedDays = widget.initialRepeatDays != null
        ? List<int>.from(widget.initialRepeatDays!)
        : [1, 2, 3, 4, 5, 6, 7];
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final safetyBottom = MediaQuery.of(context).padding.bottom;
    final totalBottom = bottomPadding > 0 ? bottomPadding : (safetyBottom > 0 ? safetyBottom : 12.0);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dividerColor = theme.dividerTheme.color ?? Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: dividerColor, width: 3),
          left: BorderSide(color: dividerColor, width: 3),
          right: BorderSide(color: dividerColor, width: 3),
        ),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 16 + totalBottom),
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
            _buildIconSection(),
            const SizedBox(height: 24),
            _buildRepeatDaysSection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
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
          color: AppColors.textTertiary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        widget.isEditing ? 'Edit Habit'.tr(context) : 'New Habit'.tr(context),
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
      ),
    );
  }

  Widget _buildNameField() {
    final selectedIcon = IconMapper.getIcon(_selectedIconCodePoint);
    final selectedColor = _hexToColor(_selectedColorHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Habit Name'.tr(context)),
        const SizedBox(height: 10),
        TextField(
          controller: _nameController,
          focusNode: _focusNode,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'e.g. Drink 2L of water'.tr(context),
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: selectedColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      selectedIcon,
                      color: selectedColor,
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

  Widget _buildIconSection() {
    final theme = Theme.of(context);
    final dividerColor = theme.dividerTheme.color ?? Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Category'.tr(context)),
        const SizedBox(height: 12),
        SizedBox(
          height: 56,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _iconOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final option = _iconOptions[index];
              final isSelected =
                  _selectedIconCodePoint == option['codePoint'];
              final accentColor = _hexToColor(_selectedColorHex);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedIconCodePoint = option['codePoint'] as String;
                    _selectedColorHex = _categoryColors[_selectedIconCodePoint]!;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? accentColor.withOpacity(0.2)
                        : (theme.cardTheme.color ?? AppColors.card),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? accentColor : dividerColor.withOpacity(0.3),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      option['icon'] as IconData,
                      color: isSelected ? accentColor : context.textSecondaryColor,
                      size: 24,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _sectionLabel('Daily Reminder'.tr(context)),
            const Spacer(),
            Switch(
              value: _notificationsEnabled,
              onChanged: (val) =>
                  setState(() => _notificationsEnabled = val),
            ),
          ],
        ),
        if (_notificationsEnabled) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.schedule_rounded,
                      color: AppColors.tealDim, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    _notificationTime.format(context),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _notificationTime = picked);
    }
  }

  Widget _buildSubmitButton() {
    final accentColor = _hexToColor(_selectedColorHex);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.black),
              )
            : Text(
                widget.isEditing ? 'Save Changes'.tr(context) : 'Add Habit'.tr(context),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _focusNode.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<HabitProvider>();
    final timeString =
        '${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')}';

    if (widget.isEditing && widget.habitId != null) {
      // Find the existing habit and update it
      final existing = provider.allHabits.firstWhere((h) => h.id == widget.habitId!);
      final updated = existing.copyWith(
        name: name,
        iconCodePoint: _selectedIconCodePoint,
        colorHex: _selectedColorHex,
        notificationsEnabled: _notificationsEnabled,
        notificationTime: timeString,
        repeatDays: _selectedDays,
      );
      await provider.updateHabit(updated);
    } else {
      await provider.addHabit(
        name: name,
        iconCodePoint: _selectedIconCodePoint,
        colorHex: _selectedColorHex,
        notificationsEnabled: _notificationsEnabled,
        notificationTime: timeString,
        repeatDays: _selectedDays,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
    );
  }

  Widget _buildRepeatDaysSection() {
    final weekdays = [
      {'val': 1, 'label': 'M'},
      {'val': 2, 'label': 'T'},
      {'val': 3, 'label': 'W'},
      {'val': 4, 'label': 'T'},
      {'val': 5, 'label': 'F'},
      {'val': 6, 'label': 'S'},
      {'val': 7, 'label': 'S'},
    ];
    final accentColor = _hexToColor(_selectedColorHex);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Repeat Days'.tr(context)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: weekdays.map((day) {
            final val = day['val'] as int;
            final label = day['label'] as String;
            final isSelected = _selectedDays.contains(val);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    if (_selectedDays.length > 1) {
                      _selectedDays.remove(val);
                    }
                  } else {
                    _selectedDays.add(val);
                    _selectedDays.sort();
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? accentColor : AppColors.card,
                  border: Border.all(
                    color: isSelected ? accentColor : AppColors.divider,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.black : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
