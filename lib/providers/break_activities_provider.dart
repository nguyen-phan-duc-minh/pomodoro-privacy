import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/break_activity.dart';

class BreakActivitiesProvider with ChangeNotifier {
  List<BreakActivity> _activities = [];
  List<ActivityHistory> _history = [];
  BreakActivity? _suggestedActivity;
  
  // Activity đang chạy
  BreakActivity? _runningActivity;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  List<BreakActivity> get activities => _activities;
  List<ActivityHistory> get history => _history;
  BreakActivity? get suggestedActivity => _suggestedActivity;
  BreakActivity? get runningActivity => _runningActivity;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;

  BreakActivitiesProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load activities (hoặc dùng mặc định)
    final activitiesJson = prefs.getString('break_activities');
    if (activitiesJson != null) {
      final List<dynamic> decoded = json.decode(activitiesJson);
      _activities = decoded.map((json) => BreakActivity.fromJson(json)).toList();
    } else {
      _activities = DefaultActivities.getAll();
    }

    // Load history
    final historyJson = prefs.getString('activity_history');
    if (historyJson != null) {
      final List<dynamic> decoded = json.decode(historyJson);
      _history = decoded.map((json) => ActivityHistory.fromJson(json)).toList();
    }

    notifyListeners();
  }

  Future<void> _saveActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_activities.map((a) => a.toJson()).toList());
    await prefs.setString('break_activities', encoded);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_history.map((h) => h.toJson()).toList());
    await prefs.setString('activity_history', encoded);
  }

  // Gợi ý 1 hoạt động mỗi category dựa trên thời gian nghỉ
  Map<ActivityCategory, BreakActivity> suggestActivitiesByCategory(int breakDurationMinutes) {
    final Map<ActivityCategory, BreakActivity> suggestions = {};
    
    // Đảm bảo có activities
    if (_activities.isEmpty) {
      _activities = DefaultActivities.getAll();
    }
    
    // Lấy lịch sử gần đây để tránh lặp lại
    final recentActivityIds = _history
        .where((h) => DateTime.now().difference(h.completedAt).inHours < 24)
        .map((h) => h.activityId)
        .toSet();

    // Với mỗi category, chọn 1 hoạt động phù hợp
    for (var category in ActivityCategory.values) {
      final categoryActivities = _activities.where((a) {
        return a.category == category && a.durationMinutes <= breakDurationMinutes;
      }).toList();

      if (categoryActivities.isEmpty) continue;

      // Ưu tiên các hoạt động chưa làm gần đây
      final notRecent = categoryActivities.where((a) => !recentActivityIds.contains(a.id)).toList();
      final pool = notRecent.isNotEmpty ? notRecent : categoryActivities;

      // Chọn ngẫu nhiên 1 hoạt động
      final random = Random();
      suggestions[category] = pool[random.nextInt(pool.length)];
    }
    
    return suggestions;
  }

  // Gợi ý hoạt động ngẫu nhiên dựa trên thời gian nghỉ (legacy)
  void suggestActivity(int breakDurationMinutes) {
    // Lọc các hoạt động phù hợp với thời gian nghỉ
    final suitable = _activities.where((a) {
      return a.durationMinutes <= breakDurationMinutes;
    }).toList();

    if (suitable.isEmpty) {
      _suggestedActivity = null;
      notifyListeners();
      return;
    }

    // Ưu tiên các hoạt động chưa làm gần đây
    final recentActivityIds = _history
        .where((h) => DateTime.now().difference(h.completedAt).inHours < 24)
        .map((h) => h.activityId)
        .toSet();

    final notRecent = suitable.where((a) => !recentActivityIds.contains(a.id)).toList();
    final pool = notRecent.isNotEmpty ? notRecent : suitable;

    // Chọn ngẫu nhiên
    final random = Random();
    _suggestedActivity = pool[random.nextInt(pool.length)];
    notifyListeners();
  }

  // Bắt đầu hoạt động với timer
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
        // Hoàn thành
        _completeCurrentActivity();
      } else {
        notifyListeners();
        _startTimer();
      }
    });
  }

  Future<void> _completeCurrentActivity() async {
    if (_runningActivity == null) return;
    
    _history.add(ActivityHistory(
      activityId: _runningActivity!.id,
      completedAt: DateTime.now(),
    ));
    await _saveHistory();
    
    _runningActivity = null;
    _remainingSeconds = 0;
    _isRunning = false;
    notifyListeners();
  }

  // Dừng activity đang chạy
  void stopActivity() {
    _runningActivity = null;
    _remainingSeconds = 0;
    _isRunning = false;
    notifyListeners();
  }

  // Đánh dấu hoàn thành hoạt động (legacy - giữ để tương thích)
  Future<void> completeActivity(String activityId) async {
    _history.add(ActivityHistory(
      activityId: activityId,
      completedAt: DateTime.now(),
    ));
    await _saveHistory();
    notifyListeners();
  }

  // Bỏ qua gợi ý hiện tại, gợi ý cái khác
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
    notifyListeners();
  }

  // Thêm hoạt động tùy chỉnh
  Future<void> addActivity(BreakActivity activity) async {
    _activities.add(activity);
    await _saveActivities();
    notifyListeners();
  }

  // Xóa hoạt động
  Future<void> removeActivity(String id) async {
    _activities.removeWhere((a) => a.id == id);
    await _saveActivities();
    notifyListeners();
  }

  // Lấy thống kê hoạt động
  Map<String, int> getActivityStats() {
    final Map<String, int> stats = {};
    for (var h in _history) {
      stats[h.activityId] = (stats[h.activityId] ?? 0) + 1;
    }
    return stats;
  }

  // Lấy hoạt động được làm nhiều nhất
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

  // Đếm số hoạt động đã làm hôm nay
  int getTodayActivityCount() {
    final today = DateTime.now();
    return _history.where((h) {
      return h.completedAt.year == today.year &&
          h.completedAt.month == today.month &&
          h.completedAt.day == today.day;
    }).length;
  }

  // Lấy danh sách hoạt động theo category
  List<BreakActivity> getActivitiesByCategory(ActivityCategory category) {
    return _activities.where((a) => a.category == category).toList();
  }

  // Reset gợi ý (dùng khi kết thúc break)
  void clearSuggestion() {
    _suggestedActivity = null;
    notifyListeners();
  }
}
