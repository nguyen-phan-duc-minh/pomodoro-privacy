import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../models/study_statistics.dart';

class GoalProvider with ChangeNotifier {
  List<Goal> _goals = [];
  SharedPreferences? _prefs;

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  List<Goal> get completedGoals => _goals.where((g) => !g.isActive).toList();

  // Lấy goals theo loại
  List<Goal> getGoalsByType(GoalType type) {
    return _goals.where((g) => g.type == type && g.isActive).toList();
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadGoals();
  }

  Future<void> _loadGoals() async {
    if (_prefs == null) return;

    final goalsJson = _prefs!.getStringList('goals') ?? [];
    _goals = goalsJson
        .map((json) => Goal.fromJson(jsonDecode(json) as Map<String, dynamic>))
        .toList();

    notifyListeners();
  }

  Future<void> _saveGoals() async {
    if (_prefs == null) return;

    final goalsJson = _goals.map((goal) => jsonEncode(goal.toJson())).toList();
    await _prefs!.setStringList('goals', goalsJson);
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

  Future<void> updateGoal(String id, {
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

    _goals[index] = _goals[index].copyWith(
      isActive: true,
      completedAt: null,
    );

    await _saveGoals();
    notifyListeners();
  }

  // Refresh để cập nhật UI khi statistics thay đổi
  void refresh() {
    notifyListeners();
  }

  // Tính thời gian học hiện tại cho goal (phút)
  int getCurrentMinutes(Goal goal, Map<String, DailyStatistics> dailyStats) {
    int totalMinutes = 0;
    final now = DateTime.now();
    
    switch (goal.type) {
      case GoalType.daily:
        // Chỉ tính thời gian học hôm nay
        final today = DateTime(now.year, now.month, now.day);
        final todayKey = today.toIso8601String().split('T')[0];
        totalMinutes = dailyStats[todayKey]?.totalStudyMinutes ?? 0;
        break;
      
      case GoalType.weekly:
        // Tính thời gian học tuần này
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekStartNormalized = DateTime(weekStart.year, weekStart.month, weekStart.day);
        
        for (int i = 0; i < 7; i++) {
          final date = weekStartNormalized.add(Duration(days: i));
          final dateKey = date.toIso8601String().split('T')[0];
          totalMinutes += dailyStats[dateKey]?.totalStudyMinutes ?? 0;
        }
        break;
      
      case GoalType.monthly:
        // Tính thời gian học tháng này
        final monthEnd = DateTime(now.year, now.month + 1, 0);
        
        for (int day = 1; day <= monthEnd.day; day++) {
          final date = DateTime(now.year, now.month, day);
          final dateKey = date.toIso8601String().split('T')[0];
          totalMinutes += dailyStats[dateKey]?.totalStudyMinutes ?? 0;
        }
        break;
      
      case GoalType.custom:
        // Tính từ ngày tạo goal đến hiện tại
        final startDate = DateTime(goal.createdAt.year, goal.createdAt.month, goal.createdAt.day);
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

  // Reset goals hàng ngày
  Future<void> resetDailyGoals() async {
    for (var i = 0; i < _goals.length; i++) {
      if (_goals[i].type == GoalType.daily && !_goals[i].isActive) {
        _goals[i] = _goals[i].copyWith(
          isActive: true,
          completedAt: null,
        );
      }
    }
    await _saveGoals();
    notifyListeners();
  }

  // Reset goals hàng tuần
  Future<void> resetWeeklyGoals() async {
    for (var i = 0; i < _goals.length; i++) {
      if (_goals[i].type == GoalType.weekly && !_goals[i].isActive) {
        _goals[i] = _goals[i].copyWith(
          isActive: true,
          completedAt: null,
        );
      }
    }
    await _saveGoals();
    notifyListeners();
  }
}
