import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/service_locator.dart';
import 'core/interfaces.dart';
import 'coordinators/timer_coordinator.dart';
import 'coordinators/timer_event_handler.dart';
import 'services/database_service.dart';
import 'services/migration_service.dart';
import 'providers/timer_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/app_theme_provider.dart';
import 'providers/task_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/achievement_provider.dart';
import 'providers/break_activities_provider.dart';
import 'screens/theme_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi', null);
  await setupDependencies();

  try {
    final migrationService = MigrationService(getIt<DatabaseService>());
    final migrated = await migrationService.migrateFromSharedPreferences();
    if (migrated) {
      print('Data migration successful');
    }
  } catch (e) {
    print('Migration error (non-critical): $e');
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
          create: (_) => AppThemeProvider(getIt<IAppThemeRepository>())..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(getIt<IThemeRepository>())..init(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              StatisticsProvider(getIt<IStatisticsRepository>())..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(getIt<ITaskRepository>())..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalProvider(getIt<IGoalRepository>())..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => BreakActivitiesProvider(
            getIt<IBreakActivityRepository>(),
          )..init(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              AchievementProvider(getIt<IAchievementRepository>())..init(),
        ),

        ChangeNotifierProvider(
          create: (context) {
            final timerProvider = TimerProvider(getIt<ISessionRepository>())
              ..init();

            final eventHandler = TimerEventHandler(
              timerProvider: timerProvider,
              coordinator: getIt<TimerCoordinator>(),
              statisticsProvider: context.read<StatisticsProvider>(),
              taskProvider: context.read<TaskProvider>(),
              goalProvider: context.read<GoalProvider>(),
              achievementProvider: context.read<AchievementProvider>(),
              breakActivitiesProvider: context.read<BreakActivitiesProvider>(),
            );

            eventHandler.setupCallbacks();

            return timerProvider;
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
