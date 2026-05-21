import 'package:hive/hive.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String iconCodePoint; // Stores the codePoint of a MaterialIcon

  @HiveField(3)
  String colorHex; // Accent color for this habit

  @HiveField(4)
  List<HabitCompletion> completions;

  @HiveField(5)
  String createdAt;

  @HiveField(6)
  bool notificationsEnabled;

  @HiveField(7)
  String notificationTime; // "HH:mm" format

  HabitModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorHex,
    required this.createdAt,
    List<HabitCompletion>? completions,
    this.notificationsEnabled = false,
    this.notificationTime = '09:00',
  }) : completions = completions ?? [];

  /// Check if this habit was completed on a given date
  bool isCompletedOn(DateTime date) {
    final key = _dateKey(date);
    return completions.any((c) => c.dateKey == key);
  }

  /// Toggle completion for a given date
  Future<void> toggleCompletion(DateTime date) async {
    final key = _dateKey(date);
    final idx = completions.indexWhere((c) => c.dateKey == key);
    if (idx >= 0) {
      completions.removeAt(idx);
    } else {
      completions.add(HabitCompletion(dateKey: key));
    }
    await save();
  }

  /// Count completions in the last [days] days
  int completionCountInDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return completions
        .where((c) => DateTime.parse(c.dateKey).isAfter(cutoff))
        .length;
  }

  /// Current streak in consecutive days up to today
  int get currentStreak {
    int streak = 0;
    DateTime day = DateTime.now();
    while (isCompletedOn(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  HabitModel copyWith({
    String? name,
    String? iconCodePoint,
    String? colorHex,
    bool? notificationsEnabled,
    String? notificationTime,
  }) {
    return HabitModel(
      id: id,
      name: name ?? this.name,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      completions: completions,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }
}

@HiveType(typeId: 1)
class HabitCompletion {
  @HiveField(0)
  String dateKey; // "yyyy-MM-dd"

  HabitCompletion({required this.dateKey});
}
