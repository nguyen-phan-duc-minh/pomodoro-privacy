import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/coordinators/timer_coordinator.dart';
import 'package:promodo_study/core/interfaces.dart';

import 'package:promodo_study/models/pomodoro_session.dart';

@GenerateMocks([IAudioService, INotificationService, IWidgetService])
import 'timer_coordinator_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimerCoordinator Tests', () {
    late TimerCoordinator coordinator;
    late MockIAudioService mockAudioService;
    late MockINotificationService mockNotificationService;
    late MockIWidgetService mockWidgetService;

    setUp(() {
      mockAudioService = MockIAudioService();
      mockNotificationService = MockINotificationService();
      mockWidgetService = MockIWidgetService();

      when(mockAudioService.playStudyStart()).thenAnswer((_) async {});
      when(mockAudioService.playStudyComplete()).thenAnswer((_) async {});
      when(mockAudioService.playBreakStart()).thenAnswer((_) async {});
      when(mockAudioService.playBreakComplete()).thenAnswer((_) async {});
      when(mockAudioService.playCycleComplete()).thenAnswer((_) async {});
      when(mockAudioService.stopBackgroundMusic()).thenAnswer((_) async {});
      when(mockNotificationService.showStudyStartNotification()).thenAnswer((_) async {});
      when(mockNotificationService.cancelAll()).thenAnswer((_) async {});
      when(mockNotificationService.showStudyCompleteNotification()).thenAnswer((_) async {});
      when(mockNotificationService.showBreakCompleteNotification()).thenAnswer((_) async {});
      when(mockNotificationService.showCycleCompleteNotification(any)).thenAnswer((_) async {});
      when(mockWidgetService.updateTimer(
        isRunning: anyNamed('isRunning'),
        remainingSeconds: anyNamed('remainingSeconds'),
        sessionType: anyNamed('sessionType'),
        themeName: anyNamed('themeName'),
        taskName: anyNamed('taskName'),
        progress: anyNamed('progress'),
      )).thenAnswer((_) async {});

      coordinator = TimerCoordinator(
        audioService: mockAudioService,
        notificationService: mockNotificationService,
        widgetService: mockWidgetService,
      );
    });

    test('On study start plays sound and shows notification', () async {
      coordinator.onStudyStart(
        session: null,
        remainingTime: 1500,
        sessionType: SessionType.study,
        themeName: 'Default',
        taskName: null,
        progress: 0.0,
      );

      await Future.delayed(Duration(milliseconds: 100));
      
      verify(mockAudioService.playStudyStart()).called(1);
      verify(mockNotificationService.showStudyStartNotification()).called(1);
    });

    test('On study complete plays sound and shows notification', () async {
      coordinator.onStudyComplete();

      await Future.delayed(Duration(milliseconds: 100));

      verify(mockAudioService.playStudyComplete()).called(1);
      verify(mockNotificationService.showStudyCompleteNotification()).called(1);
    });

    test('On break start plays sound and shows notification', () async {
      coordinator.onBreakStart(
        session: null,
        remainingTime: 300,
        sessionType: SessionType.breakTime,
        themeName: 'Default',
        taskName: null,
        progress: 0.0,
      );

      await Future.delayed(Duration(milliseconds: 100));

      verify(mockAudioService.playBreakStart()).called(1);
      verify(mockNotificationService.showBreakStartNotification()).called(1);
    });

    test('On break complete plays sound and shows notification', () async {
      coordinator.onBreakComplete();

      await Future.delayed(Duration(milliseconds: 100));

      verify(mockAudioService.playBreakComplete()).called(1);
      verify(mockNotificationService.showBreakCompleteNotification()).called(1);
    });

    test('On cycle complete plays sound and shows notification', () async {
      final session = PomodoroSession(
        id: 'session1',
        themeId: 'theme1',
        startTime: DateTime.now(),
        studyDuration: 1500,
        breakDuration: 300,
        completedCycles: 4,
        status: SessionStatus.running,
      );

      coordinator.onCycleComplete(
        session: session,
        completedCycles: 4,
        totalPomodoros: 10,
        currentStreak: 5,
        totalStudyMinutes: 250,
        todayPomodoros: 4,
        todayMinutes: 100,
      );

      await Future.delayed(Duration(milliseconds: 100));

      verify(mockAudioService.playCycleComplete()).called(1);
    });

    test('Coordinator handles service errors gracefully', () async {
      when(mockAudioService.playStudyComplete()).thenThrow(Exception('Audio error'));

      expect(() => coordinator.onStudyComplete(), returnsNormally);

      await Future.delayed(Duration(milliseconds: 100));
    });

  });
}
