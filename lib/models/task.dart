class Task {
  final String id;
  String title;
  bool completed;
  int pomodorosCompleted;
  int studyMinutes;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    required this.title,
    this.completed = false,
    this.pomodorosCompleted = 0,
    this.studyMinutes = 0,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': completed,
      'pomodorosCompleted': pomodorosCompleted,
      'studyMinutes': studyMinutes,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      completed: json['completed'] ?? false,
      pomodorosCompleted: json['pomodorosCompleted'] ?? 0,
      studyMinutes: json['studyMinutes'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? title,
    bool? completed,
    int? pomodorosCompleted,
    int? studyMinutes,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      pomodorosCompleted: pomodorosCompleted ?? this.pomodorosCompleted,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
