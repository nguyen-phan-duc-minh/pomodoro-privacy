import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/study_statistics.dart';
import '../core/interfaces.dart';

class GoalProvider with ChangeNotifier {
  final IGoalRepository _repository;
  List<Goal> _goals = [];

  GoalProvider(this._repository);

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  List<Goal> get completedGoals => _goals.where((g) => !g.isActive).toList();

  List<Goal> getGoalsByType(GoalType type) {
    return _goals.where((g) => g.type == type && g.isActive).toList();
  }

  Future<void> init() async {
    await _loadGoals();
  }

  Future<void> _loadGoals() async {
    final goalsData = await _repository.loadGoals();
    _goals = goalsData.map((json) => Goal.fromJson(json as Map<String, dynamic>)).toList();
    notifyListeners();
  }

  Future<void> _saveGoals() async {
    await _repository.saveGoals(_goals);
  }

  Future<void> addGoal({
    required String title,
    required GoalType type,
    required int targetMinutes,
  }) async {
    final goal = Goal(
      id: const Uuid().v4(),
      title: title,
      type: type,
      targetMinutes: targetMinutes,
      createdAt: DateTime.now(),
    );

    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> updateGoal(
    String id, {
    String? title,
    int? targetMinutes,
  }) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    _goals[index] = _goals[index].copyWith(
      title: title,
      targetMinutes: targetMinutes,
    );

    await _saveGoals();
    notifyListeners();
  }

  Future<void> completeGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    _goals[index] = _goals[index].copyWith(
      isActive: false,
      completedAt: DateTime.now(),
    );

    await _saveGoals();
    notifyListeners();
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> reactivateGoal(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index == -1) return;

    _goals[index] = _goals[index].copyWith(isActive: true, completedAt: null);

    await _saveGoals();
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  int getCurrentMinutes(Goal goal, Map<String, DailyStatistics> dailyStats) {
    int totalMinutes = 0;
    final now = DateTime.now();

    switch (goal.type) {
      case GoalType.daily:
        final today = DateTime(now.year, now.month, now.day);
        final todayKey = today.toIso8601String().split('T')[0];
        totalMinutes = dailyStats[todayKey]?.totalStudyMinutes ?? 0;
        break;

      case GoalType.weekly:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartNormalized = DateTime(
          weekStart.year,
          weekStart.month,
          weekStart.day,
        );

        for (int i = 0; i < 7; i++) {
          final date = weekStartNormalized.add(Duration(days: i));
          final dateKey = date.toIso8601String().split('T')[0];
          totalMinutes += dailyStats[dateKey]?.totalStudyMinutes ?? 0;
        }
        break;

      case GoalType.monthly:
        final monthEnd = DateTime(now.year, now.month + 1, 0);

        for (int day = 1; day <= monthEnd.day; day++) {
          final date = DateTime(now.year, now.month, day);
          final dateKey = date.toIso8601String().split('T')[0];
          totalMinutes += dailyStats[dateKey]?.totalStudyMinutes ?? 0;
        }
        break;

      case GoalType.custom:
        final startDate = DateTime(
          goal.createdAt.year,
          goal.createdAt.month,
          goal.createdAt.day,
        );
        final endDate = DateTime(now.year, now.month, now.day);

        DateTime current = startDate;
        while (current.isBefore(endDate) || current.isAtSameMomentAs(endDate)) {
          final dateKey = current.toIso8601String().split('T')[0];
          totalMinutes += dailyStats[dateKey]?.totalStudyMinutes ?? 0;
          current = current.add(const Duration(days: 1));
        }
        break;
    }

    return totalMinutes;
  }

  Future<void> resetDailyGoals() async {
    for (var i = 0; i < _goals.length; i++) {
      if (_goals[i].type == GoalType.daily && !_goals[i].isActive) {
        _goals[i] = _goals[i].copyWith(isActive: true, completedAt: null);
      }
    }
    await _saveGoals();
    notifyListeners();
  }

  Future<void> resetWeeklyGoals() async {
    for (var i = 0; i < _goals.length; i++) {
      if (_goals[i].type == GoalType.weekly && !_goals[i].isActive) {
        _goals[i] = _goals[i].copyWith(isActive: true, completedAt: null);
      }
    }
    await _saveGoals();
    notifyListeners();
  }
}
