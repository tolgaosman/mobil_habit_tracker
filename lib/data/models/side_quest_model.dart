/// A single daily side quest. Plain Dart class (no Hive adapter); serialized
/// to/from a Map and stored in the untyped `side_quests` box, mirroring
/// [RoutineTask].
class SideQuest {
  final String id;
  final String title; // English source string, shown via .tr(context)
  final String icon; // IconMapper key
  final String difficulty; // 'easy' | 'medium' | 'hard'
  final bool isCompleted;

  SideQuest({
    required this.id,
    required this.title,
    required this.icon,
    this.difficulty = 'easy',
    this.isCompleted = false,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'icon': icon,
      'difficulty': difficulty,
      'isCompleted': isCompleted,
    };
  }

  factory SideQuest.fromMap(Map<dynamic, dynamic> map) {
    return SideQuest(
      id: map['id'] as String,
      title: map['title'] as String,
      icon: (map['icon'] ?? 'star') as String,
      difficulty: (map['difficulty'] ?? 'easy') as String,
      isCompleted: (map['isCompleted'] ?? false) as bool,
    );
  }

  SideQuest copyWith({
    String? title,
    String? icon,
    String? difficulty,
    bool? isCompleted,
  }) {
    return SideQuest(
      id: id,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
