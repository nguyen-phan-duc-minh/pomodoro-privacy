import 'package:get_it/get_it.dart';
import '../core/interfaces.dart';
import '../core/repositories_sqlite.dart';
import '../services/database_service.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service_impl.dart';
import '../coordinators/timer_coordinator.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  getIt.registerLazySingleton(() => DatabaseService());

  await getIt<DatabaseService>().database;

  getIt.registerLazySingleton<IStatisticsRepository>(
    () => StatisticsRepositorySQLite(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<ITaskRepository>(
    () => TaskRepositorySQLite(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<ISessionRepository>(
    () => SessionRepositorySQLite(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<IGoalRepository>(
    () => GoalRepositorySQLite(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<IAchievementRepository>(
    () => AchievementRepositorySQLite(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<IThemeRepository>(
    () => ThemeRepositorySQLite(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<IBreakActivityRepository>(
    () => BreakActivityRepositorySQLite(getIt<DatabaseService>()),
  );
  getIt.registerLazySingleton<IAppThemeRepository>(
    () => AppThemeRepositorySQLite(getIt<DatabaseService>()),
  );

  getIt.registerLazySingleton<IAudioService>(() => AudioService());
  getIt.registerLazySingleton<INotificationService>(
    () => NotificationService(),
  );
  getIt.registerLazySingleton<IWidgetService>(() => WidgetServiceImpl());

  await getIt<INotificationService>().init();
  await getIt<IWidgetService>().init();
  await getIt<IStatisticsRepository>().init();
  await getIt<ITaskRepository>().init();
  await getIt<ISessionRepository>().init();
  await getIt<IGoalRepository>().init();
  await getIt<IAchievementRepository>().init();
  await getIt<IThemeRepository>().init();
  await getIt<IBreakActivityRepository>().init();
  await getIt<IAppThemeRepository>().init();

  getIt.registerLazySingleton(
    () => TimerCoordinator(
      audioService: getIt<IAudioService>(),
      notificationService: getIt<INotificationService>(),
      widgetService: getIt<IWidgetService>(),
    ),
  );
}
