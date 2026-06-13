import 'dart:convert';

import 'package:home_widget/home_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/habit_model.dart';
import '../../data/models/side_quest_model.dart';
import '../../data/models/user_model.dart';

/// Bridges the app's Hive data to the native Android home-screen widgets.
///
/// The native widgets cannot read Hive, so the app pushes a JSON snapshot of
/// today's habits / quests into the `home_widget` shared store and asks the OS
/// to redraw the widgets. A widget row tap fires [widgetBackgroundCallback]
/// (a background isolate) which toggles the real Hive data and re-pushes.
class WidgetSyncService {
  WidgetSyncService._();
  static final WidgetSyncService instance = WidgetSyncService._();

  // Shared-store keys (must match the native widget code).
  static const String keyHabitsJson = 'habits_json';
  static const String keyQuestsJson = 'quests_json';
  static const String keyHabitsEmpty = 'habits_empty_reason'; // none | logged_out
  static const String keyQuestsEmpty = 'quests_empty_reason';

  // Provider class names (must match the Kotlin classes).
  static const String habitsProvider = 'HabitsWidgetProvider';
  static const String questsProvider = 'QuestsWidgetProvider';

  static String dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> syncHabits(List<HabitModel> habits, DateTime date) async {
    final list = habits
        .map((h) => {
              'id': h.id,
              'name': h.name,
              'icon': h.iconCodePoint,
              'colorHex': h.colorHex,
              'completed': h.isCompletedOn(date),
            })
        .toList();
    await HomeWidget.saveWidgetData<String>(keyHabitsJson, jsonEncode(list));
    await HomeWidget.saveWidgetData<String>(keyHabitsEmpty, 'none');
    await HomeWidget.updateWidget(name: habitsProvider, androidName: habitsProvider);
  }

  Future<void> syncQuests(List<SideQuest> quests) async {
    final list = quests
        .map((q) => {
              'id': q.id,
              'title': q.title,
              'icon': q.icon,
              'difficulty': q.difficulty,
              'completed': q.isCompleted,
            })
        .toList();
    await HomeWidget.saveWidgetData<String>(keyQuestsJson, jsonEncode(list));
    await HomeWidget.saveWidgetData<String>(keyQuestsEmpty, 'none');
    await HomeWidget.updateWidget(name: questsProvider, androidName: questsProvider);
  }

  /// Called when no user is logged in — both widgets show a "please log in" state.
  Future<void> syncLoggedOut() async {
    await HomeWidget.saveWidgetData<String>(keyHabitsJson, '[]');
    await HomeWidget.saveWidgetData<String>(keyQuestsJson, '[]');
    await HomeWidget.saveWidgetData<String>(keyHabitsEmpty, 'logged_out');
    await HomeWidget.saveWidgetData<String>(keyQuestsEmpty, 'logged_out');
    await HomeWidget.updateWidget(name: habitsProvider, androidName: habitsProvider);
    await HomeWidget.updateWidget(name: questsProvider, androidName: questsProvider);
  }
}

String _todayKey() => WidgetSyncService.dateKey(DateTime.now());

/// Background isolate entry point: handles a widget row tap.
///
/// Runs without the app's Provider tree, so it re-opens Hive independently,
/// toggles the tapped item, and re-pushes the snapshot to the widgets.
///
/// URI format: `habitwidget://toggle?type=habit|quest&id=<id>`
@pragma('vm:entry-point')
Future<void> widgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  if (uri.host != 'toggle') return;

  final type = uri.queryParameters['type'];
  final id = uri.queryParameters['id'];
  if (id == null || id.isEmpty) return;

  await Hive.initFlutter();
  _registerAdapters();

  if (type == 'habit') {
    await _toggleHabit(id);
  } else if (type == 'quest') {
    await _toggleQuest(id);
  }
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(HabitModelAdapter());
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(HabitCompletionAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(UserModelAdapter());
}

Future<String?> _currentUserId() async {
  final box = Hive.isBoxOpen('auth_session')
      ? Hive.box<String>('auth_session')
      : await Hive.openBox<String>('auth_session');
  return box.get('current_user_id');
}

Future<void> _toggleHabit(String habitId) async {
  final userId = await _currentUserId();
  if (userId == null) return;

  final boxName = 'habits_$userId';
  final box = Hive.isBoxOpen(boxName)
      ? Hive.box<HabitModel>(boxName)
      : await Hive.openBox<HabitModel>(boxName);

  final habit = box.get(habitId);
  if (habit == null) return;

  final today = DateTime.now();
  await habit.toggleCompletion(today);
  await box.put(habit.id, habit);

  // Re-push the full habits snapshot.
  final habits = box.values.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  await WidgetSyncService.instance.syncHabits(habits, today);
}

Future<void> _toggleQuest(String questId) async {
  const boxName = 'side_quests';
  final box =
      Hive.isBoxOpen(boxName) ? Hive.box(boxName) : await Hive.openBox(boxName);

  final key = _todayKey();
  final raw = box.get(key);
  if (raw is! List) return;

  final quests = raw
      .map((v) => SideQuest.fromMap(Map<dynamic, dynamic>.from(v as Map)))
      .toList();
  final updated = quests
      .map((q) =>
          q.id == questId ? q.copyWith(isCompleted: !q.isCompleted) : q)
      .toList();

  await box.put(key, updated.map((q) => q.toMap()).toList());
  await WidgetSyncService.instance.syncQuests(updated);
}
