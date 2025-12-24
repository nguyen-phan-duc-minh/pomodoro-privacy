import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/providers/statistics_provider.dart';
import 'package:promodo_study/models/study_statistics.dart';
import 'package:promodo_study/models/pomodoro_session.dart';
import 'package:promodo_study/core/interfaces.dart';

@GenerateMocks([IStatisticsRepository])
import 'statistics_provider_test.mocks.dart';

void main() {
  group('StatisticsProvider Tests', () {
    late StatisticsProvider provider;
    late MockIStatisticsRepository mockRepository;

    setUp(() {
      mockRepository = MockIStatisticsRepository();
      when(mockRepository.init()).thenAnswer((_) async {});
      when(mockRepository.loadStatistics()).thenAnswer((_) async => null);
      when(mockRepository.saveStatistics(any)).thenAnswer((_) async {});
      
      provider = StatisticsProvider(mockRepository);
    });

    test('Initialize loads statistics from repository', () async {
      final savedStats = StudyStatistics();
      savedStats.addSession(
        date: DateTime(2025, 12, 24),
        studyMinutes: 50,
        breakMinutes: 10,
        cycles: 2,
        sessionId: 'session1',
      );

      when(mockRepository.loadStatistics()).thenAnswer((_) async => savedStats);

      await provider.init();

      expect(provider.statistics.dailyStats.isNotEmpty, true);
      verify(mockRepository.loadStatistics()).called(1);
    });

    test('Record completed session updates statistics', () async {
      await provider.init();

      final session = PomodoroSession(
        id: 'session1',
        themeId: 'theme1',
        startTime: DateTime(2025, 12, 24, 10, 0),
        endTime: DateTime(2025, 12, 24, 11, 0),
        studyDuration: 1500,
        breakDuration: 300,
        elapsedStudyTime: 1500,
        elapsedBreakTime: 300,
        completedCycles: 2,
        status: SessionStatus.completed,
      );

      await provider.recordSession(session);

      expect(provider.todayStats.totalStudyMinutes, greaterThan(0));
      verify(mockRepository.saveStatistics(any)).called(1);
    });

    test('Does not record incomplete session', () async {
      await provider.init();

      final session = PomodoroSession(
        id: 'session1',
        themeId: 'theme1',
        startTime: DateTime.now(),
        studyDuration: 1500,
        breakDuration: 300,
        status: SessionStatus.running,
      );

      await provider.recordSession(session);

      verifyNever(mockRepository.saveStatistics(any));
    });

    test('Get current streak from statistics', () async {
      await provider.init();

      expect(provider.currentStreak, isA<int>());
      expect(provider.longestStreak, isA<int>());
    });

    test('Get today stats', () async {
      await provider.init();

      final todayStats = provider.todayStats;
      
      expect(todayStats, isNotNull);
      expect(todayStats.totalStudyMinutes, isA<int>());
    });

    test('Get weekly stats', () async {
      await provider.init();

      final weeklyStats = provider.weeklyStats;
      
      expect(weeklyStats, isA<List>());
    });

    test('Get stats for specific date', () async {
      await provider.init();

      final stats = provider.getStatsForDate(DateTime(2025, 12, 24));
      
      expect(stats, isA<DailyStatistics?>());
    });
  });
}
