import '../core/interfaces.dart';
import '../models/pomodoro_session.dart';

class TimerCoordinator {
  final IAudioService audioService;
  final INotificationService notificationService;
  final IWidgetService widgetService;

  TimerCoordinator({
    required this.audioService,
    required this.notificationService,
    required this.widgetService,
  });

  Future<void> onStudyStart({
    required PomodoroSession? session,
    required int remainingTime,
    required SessionType sessionType,
    required String? themeName,
    required String? taskName,
    required double progress,
  }) async {
    try {
      await audioService.playStudyStart();
      await notificationService.showStudyStartNotification();

      if (session != null && themeName != null) {
        await widgetService.updateTimer(
          isRunning: true,
          remainingSeconds: remainingTime,
          sessionType: sessionType == SessionType.study ? 'study' : 'break',
          themeName: themeName,
          taskName: taskName,
          progress: progress,
        );
      }
    } catch (e) {}
  }

  Future<void> onStudyComplete() async {
    try {
      await audioService.playStudyComplete();
      await notificationService.showStudyCompleteNotification();
    } catch (e) {}
  }

  Future<void> onPause() async {
    try {
      await audioService.stopBackgroundMusic();
    } catch (e) {}
  }

  Future<void> onResume({required SessionType currentType}) async {
    try {
      if (currentType == SessionType.study) {
        await audioService.playBackgroundMusic();
      }
    } catch (e) {}
  }

  Future<void> onBreakStart({
    required PomodoroSession? session,
    required int remainingTime,
    required SessionType sessionType,
    required String? themeName,
    required String? taskName,
    required double progress,
  }) async {
    try {
      await audioService.playBreakStart();
      await notificationService.showBreakStartNotification();

      if (session != null && themeName != null) {
        await widgetService.updateTimer(
          isRunning: true,
          remainingSeconds: remainingTime,
          sessionType: sessionType == SessionType.study ? 'study' : 'break',
          themeName: themeName,
          taskName: taskName,
          progress: progress,
        );
      }
    } catch (e) {}
  }

  Future<void> onBreakComplete() async {
    try {
      await audioService.playBreakComplete();
      await notificationService.showBreakCompleteNotification();
    } catch (e) {}
  }

  Future<void> onCycleComplete({
    required PomodoroSession session,
    required int completedCycles,
    required int totalPomodoros,
    required int currentStreak,
    required int totalStudyMinutes,
    required int todayPomodoros,
    required int todayMinutes,
  }) async {
    try {
      await audioService.playCycleComplete();
      await notificationService.showCycleCompleteNotification(completedCycles);

      await widgetService.updateStatistics(
        todayPomodoros: todayPomodoros,
        todayMinutes: todayMinutes,
        currentStreak: currentStreak,
      );
    } catch (e) {}
  }
}
