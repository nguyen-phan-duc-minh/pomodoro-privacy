class Goal {
  final String id;
  final String title;
  final GoalType type;
  final int targetMinutes; 
  final DateTime createdAt;
  final DateTime? completedAt;
  bool isActive;

  Goal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetMinutes,
    required this.createdAt,
    this.completedAt,
    this.isActive = true,
  });

  Goal copyWith({
    String? id,
    String? title,
    GoalType? type,
    int? targetMinutes,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isActive,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.toString(),
      'targetMinutes': targetMinutes,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    int targetMins;
    if (json['targetMinutes'] != null) {
      targetMins = json['targetMinutes'] as int;
    } else if (json['targetPomodoros'] != null) {
      targetMins =
          (json['targetPomodoros'] as int) * 25; 
    } else {
      targetMins = 120; 
    }

    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      type: GoalType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => GoalType.daily,
      ),
      targetMinutes: targetMins,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  double getProgress(int currentMinutes) {
    if (targetMinutes == 0) return 0;
    return (currentMinutes / targetMinutes).clamp(0.0, 1.0);
  }

  bool isCompleted(int currentMinutes) {
    return currentMinutes >= targetMinutes;
  }

  int getRemainingMinutes(int currentMinutes) {
    return (targetMinutes - currentMinutes).clamp(0, targetMinutes);
  }
}

enum GoalType {
  daily, 
  weekly, 
  monthly, 
  custom, 
}

extension GoalTypeExtension on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.daily:
        return 'Hàng ngày';
      case GoalType.weekly:
        return 'Hàng tuần';
      case GoalType.monthly:
        return 'Hàng tháng';
      case GoalType.custom:
        return 'Tùy chỉnh';
    }
  }

  String get icon {
    switch (this) {
      case GoalType.daily:
        return '📅';
      case GoalType.weekly:
        return '📆';
      case GoalType.monthly:
        return '🗓️';
      case GoalType.custom:
        return '🎯';
    }
  }
}
