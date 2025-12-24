import 'package:home_widget/home_widget.dart';
import '../models/pomodoro_session.dart';

class WidgetService {
  static const String widgetName = 'PomodoroWidget';
  static const String androidWidgetName = 'PomodoroWidgetProvider';
  static const String iOSWidgetName = 'PomodoroWidget';
  static const String keyTimerState = 'timer_state';
  static const String keyRemainingTime = 'remaining_time';
  static const String keySessionType = 'session_type';
  static const String keyThemeName = 'theme_name';
  static const String keyTodayPomodoros = 'today_pomodoros';
  static const String keyTodayMinutes = 'today_minutes';
  static const String keyCurrentStreak = 'current_streak';
  static const String keyTaskName = 'task_name';
  static const String keyProgress = 'progress';

  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId('group.com.pomodoro.study');
    } catch (e) {}
  }

  static Future<void> updateTimer({
    required bool isRunning,
    required int remainingSeconds,
    required SessionType sessionType,
    required String themeName,
    String? taskName,
    double progress = 0.0,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(
        keyTimerState,
        isRunning ? 'running' : 'paused',
      );
      await HomeWidget.saveWidgetData<int>(keyRemainingTime, remainingSeconds);
      await HomeWidget.saveWidgetData<String>(
        keySessionType,
        sessionType == SessionType.study ? 'study' : 'break',
      );
      await HomeWidget.saveWidgetData<String>(keyThemeName, themeName);
      if (taskName != null) {
        await HomeWidget.saveWidgetData<String>(keyTaskName, taskName);
      }
      await HomeWidget.saveWidgetData<double>(keyProgress, progress);

      await _updateWidget();
    } catch (e) {}
  }

  static Future<void> updateStatistics({
    required int todayPomodoros,
    required int todayMinutes,
    required int currentStreak,
  }) async {
    try {
      await HomeWidget.saveWidgetData<int>(keyTodayPomodoros, todayPomodoros);
      await HomeWidget.saveWidgetData<int>(keyTodayMinutes, todayMinutes);
      await HomeWidget.saveWidgetData<int>(keyCurrentStreak, currentStreak);

      await _updateWidget();
    } catch (e) {}
  }

  static Future<void> clearTimer() async {
    try {
      await HomeWidget.saveWidgetData<String>(keyTimerState, 'idle');
      await HomeWidget.saveWidgetData<int>(keyRemainingTime, 0);
      await HomeWidget.saveWidgetData<String>(keyTaskName, '');

      await _updateWidget();
    } catch (e) {}
  }

  static Future<void> _updateWidget() async {
    try {
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {}
  }

  static String formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  static Future<void> registerInteractivity() async {
    try {
      HomeWidget.widgetClicked.listen((uri) {});
    } catch (e) {}
  }
}
