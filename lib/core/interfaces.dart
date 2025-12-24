abstract class INotificationService {
  Future<void> init();
  Future<void> showStudyStartNotification();
  Future<void> showStudyCompleteNotification();
  Future<void> showBreakStartNotification();
  Future<void> showBreakCompleteNotification();
  Future<void> showCycleCompleteNotification(int cycles);
  Future<void> cancelAll();
}

abstract class IAudioService {
  bool get isEnabled;
  void setEnabled(bool enabled);

  Future<void> playStudyStart();
  Future<void> playStudyComplete();
  Future<void> playBreakStart();
  Future<void> playBreakComplete();
  Future<void> playCycleComplete();
  Future<void> playBackgroundMusic();
  Future<void> stopBackgroundMusic();
}

abstract class IWidgetService {
  Future<void> init();
  Future<void> updateTimer({
    required bool isRunning,
    required int remainingSeconds,
    required String sessionType,
    required String themeName,
    String? taskName,
    double progress,
  });
  Future<void> updateStatistics({
    required int todayPomodoros,
    required int todayMinutes,
    required int currentStreak,
  });
  Future<void> clearAll();
}

abstract class IStatisticsRepository {
  Future<void> init();
  Future<void> saveStatistics(dynamic statistics);
  Future<dynamic> loadStatistics();
}

abstract class ITaskRepository {
  Future<void> init();
  Future<void> saveTasks(List<dynamic> tasks);
  Future<List<dynamic>> loadTasks();
  Future<void> saveActiveTaskId(String? taskId);
  Future<String?> loadActiveTaskId();
}

abstract class ISessionRepository {
  Future<void> init();
  Future<void> saveSession(dynamic session);
  Future<dynamic> loadSession();
  Future<void> clearSession();
}

abstract class IGoalRepository {
  Future<void> init();
  Future<void> saveGoals(List<dynamic> goals);
  Future<List<dynamic>> loadGoals();
}

abstract class IAchievementRepository {
  Future<void> init();
  Future<void> saveAchievements(List<dynamic> achievements);
  Future<List<dynamic>> loadAchievements();
}

abstract class IThemeRepository {
  Future<void> init();
  Future<void> saveCustomThemes(List<dynamic> themes);
  Future<List<dynamic>> loadCustomThemes();
}

abstract class IBreakActivityRepository {
  Future<void> init();
  Future<void> saveSelectedActivity(String? activityId);
  Future<String?> loadSelectedActivity();
}

abstract class IAppThemeRepository {
  Future<void> init();
  Future<void> saveSelectedTheme(String themeId);
  Future<String?> loadSelectedTheme();
}
