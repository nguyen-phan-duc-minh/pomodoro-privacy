import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/timer_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/app_theme_provider.dart';
import 'providers/task_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/break_activities_provider.dart';
import 'models/pomodoro_session.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'services/widget_service.dart';
import 'screens/theme_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('vi', null);
  
  try {
    await NotificationService().init();
  } catch (e) {
    // Notification service init failed, continue without notifications
  }
  
  try {
    await WidgetService.init();
    await WidgetService.registerInteractivity();
  } catch (e) {
    // Widget service init failed, continue without widgets
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppThemeProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => StatisticsProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => BreakActivitiesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AchievementProvider()..init(),
        ),
        ChangeNotifierProvider(
          create: (context) {
            final provider = TimerProvider()..init();
            
            try {
              final audioService = AudioService();
              final notificationService = NotificationService();
              final statsProvider = context.read<StatisticsProvider>();
              final taskProvider = context.read<TaskProvider>();
              final breakActivitiesProvider = context.read<BreakActivitiesProvider>();
              
              provider.onStudyStart = () {
                try {
                  audioService.playStudyStart();
                  notificationService.showStudyStartNotification();
                  
                  // Update widget
                  if (provider.currentSession != null && provider.selectedTheme != null) {
                    WidgetService.updateTimer(
                      isRunning: true,
                      remainingSeconds: provider.remainingTime,
                      sessionType: provider.currentType,
                      themeName: provider.selectedTheme!.name,
                      taskName: taskProvider.activeTask?.title,
                      progress: provider.progress,
                    );
                  }
                } catch (e) {
                  // Ignore errors
                }
              };
              
              provider.onStudyComplete = () {
                try {
                  audioService.playStudyComplete();
                  notificationService.showStudyCompleteNotification();
                } catch (e) {
                  // Ignore errors
                }
              };
              
              provider.onBreakActivityNeeded = () {
                // Callback này được gọi khi cần user chọn activity
                // Timer đã được pause trong _switchToBreak()
              };
              
              provider.onPause = () {
                try {
                  audioService.stopBackgroundMusic();
                } catch (e) {
                  // Ignore errors
                }
              };
              
              provider.onResume = () {
                try {
                  if (provider.currentType == SessionType.study) {
                    audioService.playBackgroundMusic();
                  }
                } catch (e) {
                  // Ignore errors
                }
              };
              
              provider.onBreakStart = () {
                try {
                  audioService.playBreakStart();
                  notificationService.showBreakStartNotification();
                  // Tự động gợi ý break activity
                  final breakDuration = provider.selectedTheme?.breakMinutes ?? 5;
                  breakActivitiesProvider.suggestActivity(breakDuration);
                  
                  // Update widget
                  if (provider.currentSession != null && provider.selectedTheme != null) {
                    WidgetService.updateTimer(
                      isRunning: true,
                      remainingSeconds: provider.remainingTime,
                      sessionType: provider.currentType,
                      themeName: provider.selectedTheme!.name,
                      taskName: taskProvider.activeTask?.title,
                      progress: provider.progress,
                    );
                  }
                } catch (e) {
                  // Ignore errors
                }
              };
              
              provider.onBreakComplete = () {
                try {
                  audioService.playBreakComplete();
                  notificationService.showBreakCompleteNotification();
                } catch (e) {
                  // Ignore errors
                }
              };
              
              provider.onCycleComplete = () async {
                try {
                  audioService.playCycleComplete();
                  if (provider.currentSession != null) {
                    // Lưu session vào statistics TRƯỚC
                    await statsProvider.recordSession(provider.currentSession!);
                    
                    // Tăng pomodoro cho task và hỏi hoàn thành
                    if (taskProvider.activeTask != null) {
                      final completedCycles = provider.currentSession!.completedCycles;
                      final studyMinutesPerCycle = provider.selectedTheme?.studyMinutes ?? 25;
                      for (int i = 0; i < completedCycles; i++) {
                        await taskProvider.incrementTaskPomodoro(
                          taskProvider.activeTask!.id,
                          studyMinutes: studyMinutesPerCycle,
                        );
                      }
                      
                      // Callback để hỏi người dùng
                      provider.onTaskCompletionCheck?.call(taskProvider.activeTask!);
                    }
                    
                    notificationService.showCycleCompleteNotification(
                      provider.currentSession!.completedCycles,
                    );
                    
                    // Refresh GoalProvider để cập nhật tiến độ goals
                    final goalProvider = context.read<GoalProvider>();
                    goalProvider.refresh();
                    
                    // Kiểm tra và unlock achievements SAU khi đã lưu stats
                    final achievementProvider = context.read<AchievementProvider>();
                    final todayStats = statsProvider.todayStats;
                    
                    await achievementProvider.checkAndUnlockAchievements(
                      totalPomodoros: statsProvider.getTotalCompletedCycles(),
                      currentStreak: statsProvider.currentStreak,
                      totalStudyMinutes: statsProvider.getTotalStudyMinutes(),
                      todayPomodoros: todayStats.completedCycles,
                      lastStudyTime: DateTime.now(),
                    );
                    
                    // Update widget with stats
                    WidgetService.updateStatistics(
                      todayPomodoros: todayStats.completedCycles,
                      todayMinutes: todayStats.totalStudyMinutes,
                      currentStreak: statsProvider.currentStreak,
                    );
                  }
                } catch (e) {
                  // Ignore errors
                }
              };
            } catch (e) {
              // Ignore errors
            }
            
            return provider;
          },
        ),
      ],
      child: Consumer<AppThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Pomodoro Study',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme.toThemeData(),
            home: const ThemeSelectionScreen(),
          );
        },
      ),
    );
  }
}
