import 'package:home_widget/home_widget.dart';
import '../core/interfaces.dart';

class WidgetServiceImpl implements IWidgetService {
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

  @override
  Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId('group.com.pomodoro.study');
    } catch (e) {}
  }

  @override
  Future<void> updateTimer({
    required bool isRunning,
    required int remainingSeconds,
    required String sessionType,
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
      await HomeWidget.saveWidgetData<String>(keySessionType, sessionType);
      await HomeWidget.saveWidgetData<String>(keyThemeName, themeName);
      if (taskName != null) {
        await HomeWidget.saveWidgetData<String>(keyTaskName, taskName);
      }
      await HomeWidget.saveWidgetData<double>(keyProgress, progress);

      await _updateWidget();
    } catch (e) {}
  }

  @override
  Future<void> updateStatistics({
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

  @override
  Future<void> clearAll() async {
    try {
      await HomeWidget.saveWidgetData<String>(keyTimerState, 'idle');
      await HomeWidget.saveWidgetData<int>(keyRemainingTime, 0);
      await HomeWidget.saveWidgetData<int>(keyTodayPomodoros, 0);
      await HomeWidget.saveWidgetData<int>(keyTodayMinutes, 0);
      await _updateWidget();
    } catch (e) {}
  }

  Future<void> _updateWidget() async {
    try {
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {}
  }
}
