class DailyStatistics {
  final DateTime date;
  int completedCycles;
  int totalStudyMinutes;
  int totalBreakMinutes;
  List<String> sessionIds;

  DailyStatistics({
    required this.date,
    this.completedCycles = 0,
    this.totalStudyMinutes = 0,
    this.totalBreakMinutes = 0,
    List<String>? sessionIds,
  }) : sessionIds = sessionIds ?? [];

  DateTime get normalizedDate => DateTime(date.year, date.month, date.day);

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'completedCycles': completedCycles,
      'totalStudyMinutes': totalStudyMinutes,
      'totalBreakMinutes': totalBreakMinutes,
      'sessionIds': sessionIds,
    };
  }

  factory DailyStatistics.fromJson(Map<String, dynamic> json) {
    return DailyStatistics(
      date: DateTime.parse(json['date']),
      completedCycles: json['completedCycles'] ?? 0,
      totalStudyMinutes: json['totalStudyMinutes'] ?? 0,
      totalBreakMinutes: json['totalBreakMinutes'] ?? 0,
      sessionIds: List<String>.from(json['sessionIds'] ?? []),
    );
  }

  DailyStatistics copyWith({
    DateTime? date,
    int? completedCycles,
    int? totalStudyMinutes,
    int? totalBreakMinutes,
    List<String>? sessionIds,
  }) {
    return DailyStatistics(
      date: date ?? this.date,
      completedCycles: completedCycles ?? this.completedCycles,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      totalBreakMinutes: totalBreakMinutes ?? this.totalBreakMinutes,
      sessionIds: sessionIds ?? this.sessionIds,
    );
  }
}

class StudyStatistics {
  Map<String, DailyStatistics> dailyStats;
  int currentStreak;
  int longestStreak;
  DateTime? lastStudyDate;

  StudyStatistics({
    Map<String, DailyStatistics>? dailyStats,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastStudyDate,
  }) : dailyStats = dailyStats ?? {};

  void addSession({
    required DateTime date,
    required int studyMinutes,
    required int breakMinutes,
    required int cycles,
    required String sessionId,
  }) {
    final dateKey = _dateKey(date);

    if (dailyStats.containsKey(dateKey)) {
      final stats = dailyStats[dateKey]!;
      dailyStats[dateKey] = stats.copyWith(
        completedCycles: stats.completedCycles + cycles,
        totalStudyMinutes: stats.totalStudyMinutes + studyMinutes,
        totalBreakMinutes: stats.totalBreakMinutes + breakMinutes,
        sessionIds: [...stats.sessionIds, sessionId],
      );
    } else {
      dailyStats[dateKey] = DailyStatistics(
        date: date,
        completedCycles: cycles,
        totalStudyMinutes: studyMinutes,
        totalBreakMinutes: breakMinutes,
        sessionIds: [sessionId],
      );
    }

    lastStudyDate = date;
    _updateStreak();
  }

  DailyStatistics? getStatsForDate(DateTime date) {
    return dailyStats[_dateKey(date)];
  }

  DailyStatistics getTodayStats() {
    final today = DateTime.now();
    final dateKey = _dateKey(today);
    return dailyStats[dateKey] ?? DailyStatistics(date: today);
  }

  List<DailyStatistics> getWeeklyStats() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    return List.generate(7, (index) {
      final date = weekAgo.add(Duration(days: index));
      final dateKey = _dateKey(date);
      return dailyStats[dateKey] ?? DailyStatistics(date: date);
    });
  }

  List<DailyStatistics> getMonthlyStats() {
    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));

    return List.generate(30, (index) {
      final date = monthAgo.add(Duration(days: index));
      final dateKey = _dateKey(date);
      return dailyStats[dateKey] ?? DailyStatistics(date: date);
    });
  }

  void _updateStreak() {
    if (dailyStats.isEmpty) {
      currentStreak = 0;
      return;
    }

    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    final todayKey = _dateKey(today);
    final yesterdayKey = _dateKey(yesterday);

    if (!dailyStats.containsKey(todayKey) &&
        !dailyStats.containsKey(yesterdayKey)) {
      currentStreak = 0;
      return;
    }

    int streak = 0;
    DateTime checkDate = today;

    while (true) {
      final key = _dateKey(checkDate);
      if (dailyStats.containsKey(key)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    currentStreak = streak;
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyStats': dailyStats.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
    };
  }

  factory StudyStatistics.fromJson(Map<String, dynamic> json) {
    return StudyStatistics(
      dailyStats:
          (json['dailyStats'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, DailyStatistics.fromJson(value)),
          ) ??
          {},
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'])
          : null,
    );
  }
}
