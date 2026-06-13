import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/habit_model.dart';
import '../../data/models/user_model.dart';
import '../services/notification_service.dart';
import '../services/widget_sync_service.dart';

class HabitProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  Box<HabitModel>? _box;
  String? _currentUserId;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  bool get isLoading => _currentUserId != null && _box == null;

  /// Pushes the current habit snapshot to the Android home-screen widget.
  void _syncWidget() {
    if (_box == null) return;
    WidgetSyncService.instance.syncHabits(habits, _selectedDate);
  }

  DateTime getStartingDate() {
    DateTime startingDate = DateTime(2026, 5, 20);
    if (_box == null) return startingDate;
    for (final habit in _box!.values) {
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

  List<HabitModel> get habits {
    if (_box == null) return [];

    final selectedMidnight = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final startMidnight = getStartingDate();
    if (selectedMidnight.isBefore(startMidnight)) {
      return [];
    }

    final selectedWeekday = _selectedDate.weekday;
    return _box!.values.where((habit) {
      final days = habit.repeatDays;
      if (days == null || days.isEmpty) return true;
      return days.contains(selectedWeekday);
    }).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<HabitModel> get allHabits {
    if (_box == null) return [];
    return _box!.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<HabitModel> get todayHabits => habits;

  int get completedToday =>
      habits.where((h) => h.isCompletedOn(_selectedDate)).length;

  double get completionRate =>
      habits.isEmpty ? 0 : completedToday / habits.length;

  Future<void> updateUser(UserModel? user) async {
    if (user == null) {
      if (_currentUserId != null || _box != null) {
        _box = null;
        _currentUserId = null;
        Future.microtask(() => notifyListeners());
      }
      WidgetSyncService.instance.syncLoggedOut();
      return;
    }

    if (_currentUserId == user.id) return;

    _currentUserId = user.id;
    _box = null;
    Future.microtask(() => notifyListeners());

    final boxName = 'habits_${user.id}';
    final openedBox = await Hive.openBox<HabitModel>(boxName);
    _box = openedBox;
    Future.microtask(() => notifyListeners());
    _syncWidget();
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    _syncWidget();
  }

  Future<void> addHabit({
    required String name,
    required String iconCodePoint,
    required String colorHex,
    bool notificationsEnabled = false,
    String notificationTime = '09:00',
    List<int>? repeatDays,
  }) async {
    if (_box == null) return;
    
    final habit = HabitModel(
      id: _uuid.v4(),
      name: name,
      iconCodePoint: iconCodePoint,
      colorHex: colorHex,
      createdAt: DateTime.now().toIso8601String(),
      notificationsEnabled: notificationsEnabled,
      notificationTime: notificationTime,
      repeatDays: repeatDays,
    );
    await _box!.put(habit.id, habit);

    if (notificationsEnabled) {
      await _scheduleNotification(habit);
    }

    notifyListeners();
    _syncWidget();
  }

  Future<void> updateHabit(HabitModel habit) async {
    if (_box == null) return;
    await _box!.put(habit.id, habit);

    if (habit.notificationsEnabled) {
      await _scheduleNotification(habit);
    } else {
      await NotificationService.instance.cancelNotification(habit.id);
    }

    notifyListeners();
    _syncWidget();
  }

  Future<void> deleteHabit(String habitId) async {
    if (_box == null) return;
    await NotificationService.instance.cancelNotification(habitId);
    await _box!.delete(habitId);
    notifyListeners();
    _syncWidget();
  }

  Future<void> toggleCompletion(HabitModel habit) async {
    await habit.toggleCompletion(_selectedDate);
    if (_box != null) {
      await _box!.put(habit.id, habit);
    }
    notifyListeners();
    _syncWidget();
  }

  Future<void> toggleCompletionForDate(HabitModel habit, DateTime date) async {
    await habit.toggleCompletion(date);
    if (_box != null) {
      await _box!.put(habit.id, habit);
    }
    notifyListeners();
    _syncWidget();
  }

  Future<void> _scheduleNotification(HabitModel habit) async {
    final timeParts = habit.notificationTime.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 9;
    final minute = int.tryParse(timeParts[1]) ?? 0;

    await NotificationService.instance.scheduleDailyNotification(
      id: habit.id,
      title: '⚡ Time for your habit!',
      body: 'Don\'t forget: ${habit.name}',
      hour: hour,
      minute: minute,
    );
  }

  Future<void> clearAllData() async {
    if (_box == null) return;
    for (final habit in _box!.values) {
      await NotificationService.instance.cancelNotification(habit.id);
    }
    await _box!.clear();
    notifyListeners();
    _syncWidget();
  }
}
