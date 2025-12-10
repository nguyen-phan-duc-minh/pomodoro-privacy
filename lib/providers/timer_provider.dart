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
  
  Function()? onStudyStart;
  Function()? onStudyComplete;
  Function()? onBreakStart;
  Function()? onBreakComplete;
  Function()? onCycleComplete;

  PomodoroSession? get currentSession => _currentSession;
  StudyTheme? get selectedTheme => _selectedTheme;
  bool get isRunning => _currentSession?.status == SessionStatus.running;
  bool get isPaused => _currentSession?.status == SessionStatus.paused;
  bool get isIdle => _currentSession?.status == SessionStatus.idle || _currentSession == null;

  SessionType get currentType => _currentSession?.currentType ?? SessionType.study;
  
  int get remainingTime {
    if (_currentSession == null) return 0;
    return currentType == SessionType.study
        ? _currentSession!.remainingStudyTime
        : _currentSession!.remainingBreakTime;
  }

  double get progress {
    if (_currentSession == null) return 0;
    return currentType == SessionType.study
        ? _currentSession!.studyProgress
        : _currentSession!.breakProgress;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs!.remove('current_session');
  }

  void setTheme(StudyTheme theme) {
    _selectedTheme = theme;
    notifyListeners();
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
    notifyListeners();
  }

  void resumeSession() {
    if (_currentSession == null) return;
    
    _currentSession = _currentSession!.copyWith(status: SessionStatus.running);
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
        _currentSession = _currentSession!.copyWith(
          elapsedStudyTime: _currentSession!.elapsedStudyTime + 1,
        );

        if (_currentSession!.remainingStudyTime <= 0) {
          _switchToBreak();
          return;
        }
      } else {
        _currentSession = _currentSession!.copyWith(
          elapsedBreakTime: _currentSession!.elapsedBreakTime + 1,
        );

        if (_currentSession!.remainingBreakTime <= 0) {
          _switchToStudy();
          return;
        }
      }

      _saveSession();
      notifyListeners();
    });
  }

  void _switchToBreak() {
    if (_currentSession == null) return;

    _currentSession = _currentSession!.copyWith(
      currentType: SessionType.breakTime,
    );
    
    onStudyComplete?.call();
    onBreakStart?.call();
    notifyListeners();
  }

  void _switchToStudy() {
    if (_currentSession == null) return;

    final completedCycles = _currentSession!.completedCycles + 1;
    
    onBreakComplete?.call();
    
    if (completedCycles >= _currentSession!.targetCycles) {
      onCycleComplete?.call();
      stopSession();
      return;
    }

    _currentSession = _currentSession!.copyWith(
      currentType: SessionType.study,
      completedCycles: completedCycles,
    );
    
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
