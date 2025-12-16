import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/study_theme.dart';
import '../models/pomodoro_session.dart';

class TimerProvider with ChangeNotifier {
  PomodoroSession? _currentSession;
  StudyTheme? _selectedTheme;
  Timer? _timer;
  SharedPreferences? _prefs;
  
  // Activity break tracking
  String? _currentActivityId;
  String? _currentActivityName;
  
  Function()? onStudyStart;
  Function()? onStudyComplete;
  Function()? onBreakStart;
  Function()? onBreakComplete;
  Function()? onCycleComplete;
  Function(dynamic task)? onTaskCompletionCheck;
  Function()? onBreakActivityNeeded; // Callback để hiện popup chọn activity
  Function()? onPause; // Callback khi pause
  Function()? onResume; // Callback khi resume

  PomodoroSession? get currentSession => _currentSession;
  StudyTheme? get selectedTheme => _selectedTheme;
  bool get isRunning => _currentSession?.status == SessionStatus.running;
  bool get isPaused => _currentSession?.status == SessionStatus.paused;
  bool get isIdle => _currentSession?.status == SessionStatus.idle || _currentSession == null;
  String? get currentActivityName => _currentActivityName;
  bool get hasActivity => _currentActivityId != null;

  SessionType get currentType => _currentSession?.currentType ?? SessionType.study;
  
  int get remainingTime {
    if (_currentSession == null) return 0;
    return currentType == SessionType.study ? _currentSession!.remainingStudyTime : _currentSession!.remainingBreakTime;
  }

  double get progress {
    if (_currentSession == null) return 0;
    return currentType == SessionType.study ? _currentSession!.studyProgress : _currentSession!.breakProgress;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.remove('current_session');
  }

  void setTheme(StudyTheme theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  void setBreakActivity(String activityId, String activityName, int durationMinutes) {
    _currentActivityId = activityId;
    _currentActivityName = activityName;
    
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(breakDuration: durationMinutes * 60, elapsedBreakTime: 0);
      _saveSession();
    }
    notifyListeners();
  }

  void skipBreakActivity() {
    _currentActivityId = null;
    _currentActivityName = null;
    notifyListeners();
  }

  void _clearBreakActivity() {
    _currentActivityId = null;
    _currentActivityName = null;
  }

  Future<void> startSession({int? targetCycles}) async {
    if (_selectedTheme == null) return;
    _timer?.cancel();
    _currentSession = null;
    _currentSession = PomodoroSession(
      id: const Uuid().v4(),
      themeId: _selectedTheme!.id,
      startTime: DateTime.now(),
      studyDuration: _selectedTheme!.studyMinutes * 60,
      breakDuration: _selectedTheme!.breakMinutes * 60,
      status: SessionStatus.running,
      targetCycles: targetCycles ?? 1,
    );

    _startTimer();
    await _saveSession();
    onStudyStart?.call();
    notifyListeners();
  }

  void pauseSession() {
    if (_currentSession == null) return;
    _timer?.cancel();
    _currentSession = _currentSession!.copyWith(status: SessionStatus.paused);
    _saveSession();
    onPause?.call(); 
    notifyListeners();
  }

  void resumeSession() {
    if (_currentSession == null) return;
    _currentSession = _currentSession!.copyWith(status: SessionStatus.running);
    onResume?.call(); 
    _startTimer();
    _saveSession();
    notifyListeners();
  }

  Future<void> stopSession() async {
    _timer?.cancel();
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        status: SessionStatus.completed,
        endTime: DateTime.now(),
      );
    }
    await _saveSession();
    _currentSession = null;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_currentSession == null) return;
      if (_currentSession!.currentType == SessionType.study) {
        _currentSession = _currentSession!.copyWith(elapsedStudyTime: _currentSession!.elapsedStudyTime + 1);
        if (_currentSession!.remainingStudyTime <= 0) {_switchToBreak(); return;}
      } else {
        _currentSession = _currentSession!.copyWith(elapsedBreakTime: _currentSession!.elapsedBreakTime + 1);
        if (_currentSession!.remainingBreakTime <= 0) {_switchToStudy(); return;}
      }
      _saveSession();
      notifyListeners();
    });
  }

  void _switchToBreak() {
    if (_currentSession == null) return;
    _currentSession = _currentSession!.copyWith(currentType: SessionType.breakTime,elapsedBreakTime: 0);
    _saveSession();
    _timer?.cancel(); // Pause timer ngay lập tức trước khi gọi callbacks
    _currentSession = _currentSession!.copyWith(status: SessionStatus.paused);
    onStudyComplete?.call(); // Gọi onStudyComplete để phát âm thanh
    onBreakActivityNeeded?.call(); // Gọi callback để hiện popup chọn activity
    onBreakStart?.call(); // Gọi onBreakStart 
    notifyListeners();
  }

  void _switchToStudy() {
    if (_currentSession == null) return;
    final completedCycles = _currentSession!.completedCycles + 1;
    _clearBreakActivity(); // Clear activity khi break complete
    onBreakComplete?.call();
    
    if (completedCycles >= _currentSession!.targetCycles) {
      // Cập nhật completedCycles và endTime trước khi gọi onCycleComplete
      _currentSession = _currentSession!.copyWith(completedCycles: completedCycles,status: SessionStatus.completed,endTime: DateTime.now());
      _saveSession(); // Save trước khi gọi callback
      onCycleComplete?.call();
      _timer?.cancel();
      _currentSession = null;
      notifyListeners();
      return;
    }

    _currentSession = _currentSession!.copyWith(
      currentType: SessionType.study,
      completedCycles: completedCycles,
      elapsedStudyTime: 0,
    );
    
    _saveSession();
    onStudyStart?.call();
    notifyListeners();
  }

  Future<void> _saveSession() async {
    if (_prefs == null || _currentSession == null) return;
    final json = jsonEncode(_currentSession!.toJson());
    await _prefs!.setString('current_session', json);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
