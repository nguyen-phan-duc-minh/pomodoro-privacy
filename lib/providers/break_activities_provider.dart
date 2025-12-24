import 'dart:math';
import 'package:flutter/material.dart';
import '../models/break_activity.dart';
import '../core/interfaces.dart';

class BreakActivitiesProvider with ChangeNotifier {
  final IBreakActivityRepository _repository;
  List<BreakActivity> _activities = [];
  List<ActivityHistory> _history = [];
  BreakActivity? _suggestedActivity;

  BreakActivity? _runningActivity;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  BreakActivitiesProvider(this._repository);

  List<BreakActivity> get activities => _activities;
  List<ActivityHistory> get history => _history;
  BreakActivity? get suggestedActivity => _suggestedActivity;
  BreakActivity? get runningActivity => _runningActivity;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  Future<void> init() async {
    await _loadData();
  }

  Future<void> _loadData() async {
    // Load selected activity ID from repository
    final selectedActivityId = await _repository.loadSelectedActivity();
    
    // For now, we'll use default activities and just track the selected one
    _activities = DefaultActivities.getAll();
    
    if (selectedActivityId != null) {
      try {
        _suggestedActivity = _activities.firstWhere((a) => a.id == selectedActivityId);
      } catch (e) {
        // Activity not found, ignore
      }
    }

    notifyListeners();
  }

  Future<void> _saveSelectedActivity() async {
    await _repository.saveSelectedActivity(_suggestedActivity?.id);
  }

  Future<void> _saveHistory() async {
    // History is stored separately, not in the activity repository
    // We'll keep this in memory for now or implement a separate history repository
  }

  Map<ActivityCategory, BreakActivity> suggestActivitiesByCategory(
    int breakDurationMinutes,
  ) {
    final Map<ActivityCategory, BreakActivity> suggestions = {};

    if (_activities.isEmpty) {
      _activities = DefaultActivities.getAll();
    }

    final recentActivityIds = _history
        .where((h) => DateTime.now().difference(h.completedAt).inHours < 24)
        .map((h) => h.activityId)
        .toSet();

    for (var category in ActivityCategory.values) {
      final categoryActivities = _activities.where((a) {
        return a.category == category &&
            a.durationMinutes <= breakDurationMinutes;
      }).toList();

      if (categoryActivities.isEmpty) continue;

      final notRecent = categoryActivities
          .where((a) => !recentActivityIds.contains(a.id))
          .toList();
      final pool = notRecent.isNotEmpty ? notRecent : categoryActivities;

      final random = Random();
      suggestions[category] = pool[random.nextInt(pool.length)];
    }

    return suggestions;
  }

  void suggestActivity(int breakDurationMinutes) {
    final suitable = _activities.where((a) {
      return a.durationMinutes <= breakDurationMinutes;
    }).toList();

    if (suitable.isEmpty) {
      _suggestedActivity = null;
      notifyListeners();
      return;
    }

    final recentActivityIds = _history
        .where((h) => DateTime.now().difference(h.completedAt).inHours < 24)
        .map((h) => h.activityId)
        .toSet();

    final notRecent = suitable
        .where((a) => !recentActivityIds.contains(a.id))
        .toList();
    final pool = notRecent.isNotEmpty ? notRecent : suitable;

    final random = Random();
    _suggestedActivity = pool[random.nextInt(pool.length)];
    _saveSelectedActivity();
    notifyListeners();
  }

  void startActivity(String activityId) {
    final activity = _activities.firstWhere((a) => a.id == activityId);
    _runningActivity = activity;
    _remainingSeconds = activity.durationMinutes * 60;
    _isRunning = true;
    notifyListeners();

    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isRunning || _runningActivity == null) return;

      _remainingSeconds--;

      if (_remainingSeconds <= 0) {
        _completeCurrentActivity();
      } else {
        notifyListeners();
        _startTimer();
      }
    });
  }

  Future<void> _completeCurrentActivity() async {
    if (_runningActivity == null) return;

    _history.add(
      ActivityHistory(
        activityId: _runningActivity!.id,
        completedAt: DateTime.now(),
      ),
    );
    await _saveHistory();

    _runningActivity = null;
    _remainingSeconds = 0;
    _isRunning = false;
    notifyListeners();
  }

  void stopActivity() {
    _runningActivity = null;
    _remainingSeconds = 0;
    _isRunning = false;
    notifyListeners();
  }

  Future<void> completeActivity(String activityId) async {
    _history.add(
      ActivityHistory(activityId: activityId, completedAt: DateTime.now()),
    );
    await _saveHistory();
    notifyListeners();
  }

  void skipSuggestion(int breakDurationMinutes) {
    final currentId = _suggestedActivity?.id;
    final suitable = _activities.where((a) {
      return a.durationMinutes <= breakDurationMinutes && a.id != currentId;
    }).toList();

    if (suitable.isEmpty) {
      _suggestedActivity = null;
      notifyListeners();
      return;
    }

    final random = Random();
    _suggestedActivity = suitable[random.nextInt(suitable.length)];
    _saveSelectedActivity();
    notifyListeners();
  }

  Future<void> addActivity(BreakActivity activity) async {
    _activities.add(activity);
    notifyListeners();
  }

  Future<void> removeActivity(String id) async {
    _activities.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  Map<String, int> getActivityStats() {
    final Map<String, int> stats = {};
    for (var h in _history) {
      stats[h.activityId] = (stats[h.activityId] ?? 0) + 1;
    }
    return stats;
  }

  BreakActivity? getMostFrequentActivity() {
    if (_history.isEmpty) return null;

    final stats = getActivityStats();
    final mostFrequentId = stats.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return _activities.firstWhere(
      (a) => a.id == mostFrequentId,
      orElse: () => _activities.first,
    );
  }

  int getTodayActivityCount() {
    final today = DateTime.now();
    return _history.where((h) {
      return h.completedAt.year == today.year &&
          h.completedAt.month == today.month &&
          h.completedAt.day == today.day;
    }).length;
  }

  List<BreakActivity> getActivitiesByCategory(ActivityCategory category) {
    return _activities.where((a) => a.category == category).toList();
  }

  void clearSuggestion() {
    _suggestedActivity = null;
    _saveSelectedActivity();
    notifyListeners();
  }
}
