import 'package:flutter/material.dart';
import '../core/interfaces.dart';
import '../models/study_statistics.dart';
import '../models/pomodoro_session.dart';

class StatisticsProvider with ChangeNotifier {
  final IStatisticsRepository _repository;
  StudyStatistics _statistics = StudyStatistics();

  StatisticsProvider(this._repository);

  StudyStatistics get statistics => _statistics;
  int get currentStreak => _statistics.currentStreak;
  int get longestStreak => _statistics.longestStreak;

  DailyStatistics get todayStats => _statistics.getTodayStats();
  List<DailyStatistics> get weeklyStats => _statistics.getWeeklyStats();
  List<DailyStatistics> get monthlyStats => _statistics.getMonthlyStats();

  Future<void> init() async {
    await _repository.init();
    await _loadStatistics();
  }

  Future<void> recordSession(PomodoroSession session) async {
    if (session.status != SessionStatus.completed) {
      return;
    }

    final studyMinutes = (session.totalStudyTime / 60).round();
    final breakMinutes = (session.totalBreakTime / 60).round();

    _statistics.addSession(
      date: session.startTime,
      studyMinutes: studyMinutes,
      breakMinutes: breakMinutes,
      cycles: session.completedCycles,
      sessionId: session.id,
    );

    await _saveStatistics();
    notifyListeners();
  }

  DailyStatistics? getStatsForDate(DateTime date) {
    return _statistics.getStatsForDate(date);
  }

  int getTotalStudyMinutes() {
    int total = 0;
    for (var stats in _statistics.dailyStats.values) {
      total += stats.totalStudyMinutes;
    }
    return total;
  }

  int getTotalCompletedCycles() {
    int total = 0;
    for (var stats in _statistics.dailyStats.values) {
      total += stats.completedCycles;
    }
    return total;
  }

  List<DailyStatistics> getStatsForDateRange(DateTime start, DateTime end) {
    final List<DailyStatistics> result = [];
    DateTime current = start;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final stats = _statistics.getStatsForDate(current);
      if (stats != null) {
        result.add(stats);
      } else {
        result.add(DailyStatistics(date: current));
      }
      current = current.add(const Duration(days: 1));
    }

    return result;
  }

  Future<void> _saveStatistics() async {
    await _repository.saveStatistics(_statistics);
  }

  Future<void> _loadStatistics() async {
    final loaded = await _repository.loadStatistics();
    if (loaded != null) {
      _statistics = loaded;
      notifyListeners();
    }
  }

  Future<void> clearAllData() async {
    _statistics = StudyStatistics();
    await _saveStatistics();
    notifyListeners();
  }
}
