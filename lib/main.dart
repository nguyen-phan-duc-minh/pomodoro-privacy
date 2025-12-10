import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/timer_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/app_theme_provider.dart';
import 'services/audio_service.dart';
import 'services/notification_service.dart';
import 'screens/theme_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('vi', null);
  
  try {
    await NotificationService().init();
  } catch (e) {
    // Notification service init failed, continue without notifications
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
          create: (context) {
            final provider = TimerProvider()..init();
            
            try {
              final audioService = AudioService();
              final notificationService = NotificationService();
              final statsProvider = context.read<StatisticsProvider>();
              
              provider.onStudyStart = () {
                try {
                  audioService.playStudyStart();
                  notificationService.showStudyStartNotification();
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
              
              provider.onBreakStart = () {
                try {
                  audioService.playBreakStart();
                  notificationService.showBreakStartNotification();
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
              
              provider.onCycleComplete = () {
                try {
                  audioService.playCycleComplete();
                  if (provider.currentSession != null) {
                    statsProvider.recordSession(provider.currentSession!);
                    notificationService.showCycleCompleteNotification(
                      provider.currentSession!.completedCycles,
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
