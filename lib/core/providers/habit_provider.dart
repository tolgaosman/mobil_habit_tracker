import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/habit_model.dart';
import '../services/notification_service.dart';

class HabitProvider extends ChangeNotifier {
  final Box<HabitModel> _box = Hive.box<HabitModel>('habits');
  final _uuid = const Uuid();

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  List<HabitModel> get habits => _box.values.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  List<HabitModel> get todayHabits => habits;

  int get completedToday =>
      habits.where((h) => h.isCompletedOn(_selectedDate)).length;

  double get completionRate =>
      habits.isEmpty ? 0 : completedToday / habits.length;

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> addHabit({
    required String name,
    required String iconCodePoint,
    required String colorHex,
    bool notificationsEnabled = false,
    String notificationTime = '09:00',
  }) async {
    final habit = HabitModel(
      id: _uuid.v4(),
      name: name,
      iconCodePoint: iconCodePoint,
      colorHex: colorHex,
      createdAt: DateTime.now().toIso8601String(),
      notificationsEnabled: notificationsEnabled,
      notificationTime: notificationTime,
    );
    await _box.put(habit.id, habit);

    if (notificationsEnabled) {
      await _scheduleNotification(habit);
    }

    notifyListeners();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await habit.save();

    if (habit.notificationsEnabled) {
      await _scheduleNotification(habit);
    } else {
      await NotificationService.instance.cancelNotification(habit.id);
    }

    notifyListeners();
  }

  Future<void> deleteHabit(String habitId) async {
    await NotificationService.instance.cancelNotification(habitId);
    await _box.delete(habitId);
    notifyListeners();
  }

  Future<void> toggleCompletion(HabitModel habit) async {
    await habit.toggleCompletion(_selectedDate);
    notifyListeners();
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
}
