import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/side_quest_model.dart';

/// Global (not per-user) provider for the daily Side Quests feature.
///
/// Each day gets 3 randomly chosen quests from [_pool]. The chosen set is
/// generated the first time a day is opened and then persisted, so the same 3
/// quests stay fixed for that day. Data is stored in the untyped `side_quests`
/// Hive box, keyed by date-key string (`YYYY-MM-DD`), value = list of quest maps.
class SideQuestProvider extends ChangeNotifier {
  static const String boxName = 'side_quests';

  final _uuid = const Uuid();
  final _random = Random();
  Box? _box;

  bool get isLoading => _box == null;

  /// Difficulty tiers, ordered easy → medium → hard. Each day picks one quest
  /// from each tier. `title` is an English source string (shown via
  /// `.tr(context)`); `icon` is an [IconMapper] key.
  static const List<String> difficulties = ['easy', 'medium', 'hard'];

  static const Map<String, List<Map<String, String>>> _pools = {
    'easy': [
      {'title': 'Drink a glass of water', 'icon': 'water'},
      {'title': 'Make your bed', 'icon': 'sleep'},
      {'title': 'Take 5 deep breaths', 'icon': 'mind'},
      {'title': 'Eat a piece of fruit', 'icon': 'food'},
      {'title': 'Smile at a stranger', 'icon': 'heart'},
      {'title': 'Step outside for fresh air', 'icon': 'mind'},
      {'title': 'Listen to a favorite song', 'icon': 'music'},
      {'title': 'Say thank you to someone', 'icon': 'heart'},
      {'title': 'Stand up and stretch your back', 'icon': 'gym'},
      {'title': 'Compliment someone today', 'icon': 'heart'},
      {'title': 'Clean your phone screen', 'icon': 'technology'},
      {'title': 'Learn one new word', 'icon': 'education'},
    ],
    'medium': [
      {'title': 'Take a 10-minute walk', 'icon': 'run'},
      {'title': 'Tidy up your desk', 'icon': 'other'},
      {'title': 'Read one page of a book', 'icon': 'book'},
      {'title': 'Text a friend you miss', 'icon': 'heart'},
      {'title': 'Wash the dishes', 'icon': 'water'},
      {'title': 'Water a plant', 'icon': 'nutrition'},
      {'title': 'Write one sentence in a journal', 'icon': 'book'},
      {'title': 'Take the stairs instead of the elevator', 'icon': 'exercise'},
      {'title': 'Do a 1-minute meditation', 'icon': 'mind'},
      {'title': 'Drink a cup of tea mindfully', 'icon': 'food'},
      {'title': 'Write down one thing you are grateful for', 'icon': 'star'},
      {'title': 'Take a photo of something beautiful', 'icon': 'star'},
    ],
    'hard': [
      {'title': 'Do 20 push-ups', 'icon': 'exercise'},
      {'title': 'Put your phone away for 1 hour', 'icon': 'technology'},
      {'title': 'Declutter and organize one drawer', 'icon': 'other'},
      {'title': 'Plan tomorrow in 3 bullet points', 'icon': 'education'},
      {'title': 'Avoid sugar for the whole day', 'icon': 'nutrition'},
      {'title': 'Go to bed 30 minutes earlier', 'icon': 'sleep'},
      {'title': 'Do a 20-minute workout', 'icon': 'gym'},
      {'title': 'Read a full chapter of a book', 'icon': 'book'},
      {'title': 'Take a 30-minute screen-free break', 'icon': 'technology'},
      {'title': 'Cook a meal from scratch', 'icon': 'food'},
      {'title': 'Go for a 30-minute run', 'icon': 'run'},
      {'title': 'Meditate for 10 minutes', 'icon': 'mind'},
    ],
  };

  Future<void> init() async {
    if (Hive.isBoxOpen(boxName)) {
      _box = Hive.box(boxName);
    } else {
      _box = await Hive.openBox(boxName);
    }
    ensureTodayGenerated();
    notifyListeners();
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String get _todayKey => _dateKey(DateTime.now());

  List<SideQuest> _parse(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .map((v) => SideQuest.fromMap(Map<dynamic, dynamic>.from(v as Map)))
        .toList();
  }

  /// Generates and persists today's quests if they don't exist yet.
  void ensureTodayGenerated() {
    if (_box == null) return;
    if (_box!.containsKey(_todayKey)) return;

    final quests = difficulties.map((difficulty) {
      final pool = _pools[difficulty]!;
      final entry = pool[_random.nextInt(pool.length)];
      return SideQuest(
        id: _uuid.v4(),
        title: entry['title']!,
        icon: entry['icon']!,
        difficulty: difficulty,
        isCompleted: false,
      );
    }).toList();

    _box!.put(_todayKey, quests.map((q) => q.toMap()).toList());
  }

  List<SideQuest> get todayQuests {
    if (_box == null) return [];
    ensureTodayGenerated();
    return _parse(_box!.get(_todayKey));
  }

  Future<void> toggleCompletion(SideQuest quest) async {
    if (_box == null) return;

    final quests = todayQuests;
    final updated = quests
        .map((q) =>
            q.id == quest.id ? q.copyWith(isCompleted: !q.isCompleted) : q)
        .toList();

    await _box!.put(_todayKey, updated.map((q) => q.toMap()).toList());
    notifyListeners();
  }

  /// Past days' quests, keyed by date-key, sorted descending (newest first).
  /// Excludes today.
  List<MapEntry<String, List<SideQuest>>> get history {
    if (_box == null) return [];
    final today = _todayKey;
    final entries = _box!.keys
        .where((k) => k is String && k != today)
        .map((k) => MapEntry(k as String, _parse(_box!.get(k))))
        .where((e) => e.value.isNotEmpty)
        .toList();
    entries.sort((a, b) => b.key.compareTo(a.key));
    return entries;
  }
}
