import '../providers/timer_provider.dart';
import '../providers/statistics_provider.dart';
import '../providers/task_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/break_activities_provider.dart';
import '../coordinators/timer_coordinator.dart';

class TimerEventHandler {
  final TimerProvider timerProvider;
  final TimerCoordinator coordinator;
  final StatisticsProvider statisticsProvider;
  final TaskProvider taskProvider;
  final GoalProvider goalProvider;
  final AchievementProvider achievementProvider;
  final BreakActivitiesProvider breakActivitiesProvider;

  TimerEventHandler({
    required this.timerProvider,
    required this.coordinator,
    required this.statisticsProvider,
    required this.taskProvider,
    required this.goalProvider,
    required this.achievementProvider,
    required this.breakActivitiesProvider,
  });

  void setupCallbacks() {
    timerProvider.onStudyStart = _handleStudyStart;
    timerProvider.onStudyComplete = _handleStudyComplete;
    timerProvider.onBreakStart = _handleBreakStart;
    timerProvider.onBreakComplete = _handleBreakComplete;
    timerProvider.onCycleComplete = _handleCycleComplete;
    timerProvider.onPause = _handlePause;
    timerProvider.onResume = _handleResume;
    timerProvider.onBreakActivityNeeded = _handleBreakActivityNeeded;
  }

  void _handleStudyStart() {
    coordinator.onStudyStart(
      session: timerProvider.currentSession,
      remainingTime: timerProvider.remainingTime,
      sessionType: timerProvider.currentType,
      themeName: timerProvider.selectedTheme?.name,
      taskName: taskProvider.activeTask?.title,
      progress: timerProvider.progress,
    );
  }

  void _handleStudyComplete() {
    coordinator.onStudyComplete();
  }

  void _handlePause() {
    coordinator.onPause();
  }

  void _handleResume() {
    coordinator.onResume(currentType: timerProvider.currentType);
  }

  void _handleBreakStart() {
    final breakDuration = timerProvider.selectedTheme?.breakMinutes ?? 5;
    breakActivitiesProvider.suggestActivity(breakDuration);

    coordinator.onBreakStart(
      session: timerProvider.currentSession,
      remainingTime: timerProvider.remainingTime,
      sessionType: timerProvider.currentType,
      themeName: timerProvider.selectedTheme?.name,
      taskName: taskProvider.activeTask?.title,
      progress: timerProvider.progress,
    );
  }

  void _handleBreakComplete() {
    coordinator.onBreakComplete();
  }

  void _handleBreakActivityNeeded() {}

  Future<void> _handleCycleComplete() async {
    try {
      final session = timerProvider.currentSession;
      if (session == null) return;

      await statisticsProvider.recordSession(session);

      if (taskProvider.activeTask != null) {
        final completedCycles = session.completedCycles;
        final studyMinutesPerCycle =
            timerProvider.selectedTheme?.studyMinutes ?? 25;

        for (int i = 0; i < completedCycles; i++) {
          await taskProvider.incrementTaskPomodoro(
            taskProvider.activeTask!.id,
            studyMinutes: studyMinutesPerCycle,
          );
        }

        timerProvider.onTaskCompletionCheck?.call(taskProvider.activeTask!);
      }

      goalProvider.refresh();

      final todayStats = statisticsProvider.todayStats;
      await achievementProvider.checkAndUnlockAchievements(
        totalPomodoros: statisticsProvider.getTotalCompletedCycles(),
        currentStreak: statisticsProvider.currentStreak,
        totalStudyMinutes: statisticsProvider.getTotalStudyMinutes(),
        todayPomodoros: todayStats.completedCycles,
        lastStudyTime: DateTime.now(),
      );

      await coordinator.onCycleComplete(
        session: session,
        completedCycles: session.completedCycles,
        totalPomodoros: statisticsProvider.getTotalCompletedCycles(),
        currentStreak: statisticsProvider.currentStreak,
        totalStudyMinutes: statisticsProvider.getTotalStudyMinutes(),
        todayPomodoros: todayStats.completedCycles,
        todayMinutes: todayStats.totalStudyMinutes,
      );
    } catch (e) {}
  }
}
