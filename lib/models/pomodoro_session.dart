enum SessionType { study, breakTime }

enum SessionStatus { idle, running, paused, completed }

class PomodoroSession {
  final String id;
  final String themeId;
  final DateTime startTime;
  DateTime? endTime;
  final int studyDuration; 
  final int breakDuration; 
  int elapsedStudyTime; 
  int elapsedBreakTime; 
  SessionType currentType;
  SessionStatus status;
  int completedCycles;
  int targetCycles;

  PomodoroSession({
    required this.id,
    required this.themeId,
    required this.startTime,
    this.endTime,
    required this.studyDuration,
    required this.breakDuration,
    this.elapsedStudyTime = 0,
    this.elapsedBreakTime = 0,
    this.currentType = SessionType.study,
    this.status = SessionStatus.idle,
    this.completedCycles = 0,
    this.targetCycles = 1,
  });

  int get totalStudyTime => elapsedStudyTime;
  int get totalBreakTime => elapsedBreakTime;
  int get totalTime => totalStudyTime + totalBreakTime;

  double get studyProgress {
    if (studyDuration == 0) return 0;
    return (elapsedStudyTime % studyDuration) / studyDuration;
  }

  double get breakProgress {
    if (breakDuration == 0) return 0;
    return (elapsedBreakTime % breakDuration) / breakDuration;
  }

  int get remainingStudyTime {
    final currentCycleTime = elapsedStudyTime % studyDuration;
    return studyDuration - currentCycleTime;
  }

  int get remainingBreakTime {
    final currentCycleTime = elapsedBreakTime % breakDuration;
    return breakDuration - currentCycleTime;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'themeId': themeId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'studyDuration': studyDuration,
      'breakDuration': breakDuration,
      'elapsedStudyTime': elapsedStudyTime,
      'elapsedBreakTime': elapsedBreakTime,
      'currentType': currentType.index,
      'status': status.index,
      'completedCycles': completedCycles,
      'targetCycles': targetCycles,
    };
  }

  factory PomodoroSession.fromJson(Map<String, dynamic> json) {
    return PomodoroSession(
      id: json['id'],
      themeId: json['themeId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      studyDuration: json['studyDuration'],
      breakDuration: json['breakDuration'],
      elapsedStudyTime: json['elapsedStudyTime'] ?? 0,
      elapsedBreakTime: json['elapsedBreakTime'] ?? 0,
      currentType: SessionType.values[json['currentType'] ?? 0],
      status: SessionStatus.values[json['status'] ?? 0],
      completedCycles: json['completedCycles'] ?? 0,
      targetCycles: json['targetCycles'] ?? 1,
    );
  }

  PomodoroSession copyWith({
    String? id,
    String? themeId,
    DateTime? startTime,
    DateTime? endTime,
    int? studyDuration,
    int? breakDuration,
    int? elapsedStudyTime,
    int? elapsedBreakTime,
    SessionType? currentType,
    SessionStatus? status,
    int? completedCycles,
    int? targetCycles,
  }) {
    return PomodoroSession(
      id: id ?? this.id,
      themeId: themeId ?? this.themeId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      studyDuration: studyDuration ?? this.studyDuration,
      breakDuration: breakDuration ?? this.breakDuration,
      elapsedStudyTime: elapsedStudyTime ?? this.elapsedStudyTime,
      elapsedBreakTime: elapsedBreakTime ?? this.elapsedBreakTime,
      currentType: currentType ?? this.currentType,
      status: status ?? this.status,
      completedCycles: completedCycles ?? this.completedCycles,
      targetCycles: targetCycles ?? this.targetCycles,
    );
  }
}
