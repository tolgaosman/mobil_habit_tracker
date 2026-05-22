class RoutineTask {
  final String id;
  final String title;
  final String time; // "HH:mm"
  final bool isCompleted;

  RoutineTask({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });

  Map<dynamic, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'isCompleted': isCompleted,
    };
  }

  factory RoutineTask.fromMap(Map<dynamic, dynamic> map) {
    return RoutineTask(
      id: map['id'] as String,
      title: map['title'] as String,
      time: map['time'] as String,
      isCompleted: (map['isCompleted'] ?? false) as bool,
    );
  }

  RoutineTask copyWith({
    String? title,
    String? time,
    bool? isCompleted,
  }) {
    return RoutineTask(
      id: id,
      title: title ?? this.title,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
