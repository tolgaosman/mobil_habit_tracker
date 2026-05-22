import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/routine_task_model.dart';
import '../../data/models/user_model.dart';
import '../services/notification_service.dart';

class RoutineProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  Box? _box;
  String? _currentUserId;

  bool get isLoading => _currentUserId != null && _box == null;

  List<RoutineTask> get routines {
    if (_box == null) return [];
    final list = _box!.values.map((v) => RoutineTask.fromMap(Map<dynamic, dynamic>.from(v as Map))).toList();
    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  Future<void> updateUser(UserModel? user) async {
    if (user == null) {
      if (_currentUserId != null || _box != null) {
        _box = null;
        _currentUserId = null;
        Future.microtask(() => notifyListeners());
      }
      return;
    }

    if (_currentUserId == user.id) return;

    _currentUserId = user.id;
    _box = null;
    Future.microtask(() => notifyListeners());

    final boxName = 'routines_${user.id}';
    final openedBox = await Hive.openBox(boxName);
    _box = openedBox;
    Future.microtask(() => notifyListeners());
  }

  Future<void> addRoutine(String title, String time) async {
    if (_box == null) return;

    final task = RoutineTask(
      id: _uuid.v4(),
      title: title.trim(),
      time: time,
      isCompleted: false,
    );

    await _box!.put(task.id, task.toMap());
    await _scheduleNotification(task);
    notifyListeners();
  }

  Future<void> updateRoutine(RoutineTask task) async {
    if (_box == null) return;

    await _box!.put(task.id, task.toMap());
    await _scheduleNotification(task);
    notifyListeners();
  }

  Future<void> deleteRoutine(String id) async {
    if (_box == null) return;

    await NotificationService.instance.cancelNotification(id);
    await _box!.delete(id);
    notifyListeners();
  }

  Future<void> toggleCompletion(RoutineTask task) async {
    if (_box == null) return;

    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _box!.put(updated.id, updated.toMap());
    notifyListeners();
  }

  Future<void> resetAllCompletions() async {
    if (_box == null) return;

    for (final task in routines) {
      if (task.isCompleted) {
        final updated = task.copyWith(isCompleted: false);
        await _box!.put(updated.id, updated.toMap());
      }
    }
    notifyListeners();
  }

  Future<void> _scheduleNotification(RoutineTask task) async {
    final parts = task.time.split(':');
    final hour = int.tryParse(parts[0]) ?? 9;
    final minute = int.tryParse(parts[1]) ?? 0;

    await NotificationService.instance.scheduleDailyNotification(
      id: task.id,
      title: 'Routine Reminder ⏰',
      body: 'It is time for: ${task.title}',
      hour: hour,
      minute: minute,
    );
  }
}
