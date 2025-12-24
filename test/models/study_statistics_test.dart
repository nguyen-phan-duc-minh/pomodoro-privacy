import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/models/study_statistics.dart';

void main() {
  group('DailyStatistics Tests', () {
    test('Create daily statistics with defaults', () {
      final date = DateTime(2025, 12, 24);
      final stats = DailyStatistics(date: date);

      expect(stats.date, date);
      expect(stats.completedCycles, 0);
      expect(stats.totalStudyMinutes, 0);
      expect(stats.totalBreakMinutes, 0);
      expect(stats.sessionIds, isEmpty);
    });

    test('Normalized date removes time', () {
      final stats = DailyStatistics(date: DateTime(2025, 12, 24, 15, 30, 45));

      final normalized = stats.normalizedDate;
      expect(normalized.hour, 0);
      expect(normalized.minute, 0);
      expect(normalized.second, 0);
      expect(normalized.day, 24);
      expect(normalized.month, 12);
      expect(normalized.year, 2025);
    });

    test('toJson and fromJson work correctly', () {
      final stats = DailyStatistics(
        date: DateTime(2025, 12, 24),
        completedCycles: 5,
        totalStudyMinutes: 125,
        totalBreakMinutes: 25,
        sessionIds: ['session1', 'session2'],
      );

      final json = stats.toJson();
      final fromJson = DailyStatistics.fromJson(json);

      expect(fromJson.date, stats.date);
      expect(fromJson.completedCycles, stats.completedCycles);
      expect(fromJson.totalStudyMinutes, stats.totalStudyMinutes);
      expect(fromJson.totalBreakMinutes, stats.totalBreakMinutes);
      expect(fromJson.sessionIds, stats.sessionIds);
    });
  });

  group('StudyStatistics Tests', () {
    test('Create empty statistics', () {
      final stats = StudyStatistics();

      expect(stats.dailyStats, isEmpty);
      expect(stats.currentStreak, 0);
      expect(stats.longestStreak, 0);
      expect(stats.lastStudyDate, null);
    });

    test('Add session creates daily statistics', () {
      final stats = StudyStatistics();
      final today = DateTime(2025, 12, 24);

      stats.addSession(
        date: today,
        studyMinutes: 25,
        breakMinutes: 5,
        cycles: 1,
        sessionId: 'session1',
      );

      final todayStats = stats.getTodayStats();
      expect(todayStats.totalStudyMinutes, 25);
      expect(todayStats.totalBreakMinutes, 5);
      expect(todayStats.completedCycles, 1);
      expect(todayStats.sessionIds, contains('session1'));
    });

    test('Multiple sessions accumulate in same day', () {
      final stats = StudyStatistics();
      final today = DateTime(2025, 12, 24);

      stats.addSession(
        date: today,
        studyMinutes: 25,
        breakMinutes: 5,
        cycles: 1,
        sessionId: 'session1',
      );

      stats.addSession(
        date: today,
        studyMinutes: 25,
        breakMinutes: 5,
        cycles: 1,
        sessionId: 'session2',
      );

      final todayStats = stats.getTodayStats();
      expect(todayStats.totalStudyMinutes, 50);
      expect(todayStats.totalBreakMinutes, 10);
      expect(todayStats.completedCycles, 2);
      expect(todayStats.sessionIds.length, 2);
    });

    test('Streak calculation for consecutive days', () {
      final stats = StudyStatistics();
      final today = DateTime(2025, 12, 24);

      for (int i = 0; i < 3; i++) {
        final date = today.subtract(Duration(days: i));
        stats.addSession(
          date: date,
          studyMinutes: 25,
          breakMinutes: 5,
          cycles: 1,
          sessionId: 'session$i',
        );
      }

      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, 3);
    });

    test('Streak breaks with missed day', () {
      final stats = StudyStatistics();
      final today = DateTime(2025, 12, 24);

      stats.addSession(
        date: today,
        studyMinutes: 25,
        breakMinutes: 5,
        cycles: 1,
        sessionId: 'session1',
      );

      stats.addSession(
        date: today.subtract(const Duration(days: 2)),
        studyMinutes: 25,
        breakMinutes: 5,
        cycles: 1,
        sessionId: 'session2',
      );

      expect(stats.currentStreak, 1);
    });

    test('Get stats for specific date', () {
      final stats = StudyStatistics();
      final targetDate = DateTime(2025, 12, 20);

      stats.addSession(
        date: targetDate,
        studyMinutes: 50,
        breakMinutes: 10,
        cycles: 2,
        sessionId: 'session1',
      );

      final dateStats = stats.getStatsForDate(targetDate);
      expect(dateStats, isNotNull);
      expect(dateStats!.totalStudyMinutes, 50);
      expect(dateStats.completedCycles, 2);
    });

    test('Get weekly stats returns 7 days', () {
      final stats = StudyStatistics();
      final today = DateTime(2025, 12, 24);

      for (int i = 0; i < 7; i++) {
        final date = today.subtract(Duration(days: i));
        stats.addSession(
          date: date,
          studyMinutes: 25,
          breakMinutes: 5,
          cycles: 1,
          sessionId: 'session$i',
        );
      }

      final weeklyStats = stats.getWeeklyStats();
      expect(weeklyStats.length, 7);
    });

    test('Get monthly stats returns 30 days', () {
      final stats = StudyStatistics();
      final monthlyStats = stats.getMonthlyStats();

      expect(monthlyStats.length, 30);
    });

    test('Longest streak updates correctly', () {
      final stats = StudyStatistics();
      final today = DateTime(2025, 12, 24);

      for (int i = 4; i >= 0; i--) {
        final date = today.subtract(Duration(days: i + 10));
        stats.addSession(
          date: date,
          studyMinutes: 25,
          breakMinutes: 5,
          cycles: 1,
          sessionId: 'old_$i',
        );
      }


      for (int i = 2; i >= 0; i--) {
        final date = today.subtract(Duration(days: i));
        stats.addSession(
          date: date,
          studyMinutes: 25,
          breakMinutes: 5,
          cycles: 1,
          sessionId: 'new_$i',
        );
      }

      expect(stats.currentStreak, 3);
      expect(stats.longestStreak, greaterThanOrEqualTo(3));
    });

    test('toJson and fromJson preserve all data', () {
      final stats = StudyStatistics();
      final today = DateTime(2025, 12, 24);

      stats.addSession(
        date: today,
        studyMinutes: 50,
        breakMinutes: 10,
        cycles: 2,
        sessionId: 'session1',
      );

      final json = stats.toJson();
      final fromJson = StudyStatistics.fromJson(json);

      expect(fromJson.currentStreak, stats.currentStreak);
      expect(fromJson.longestStreak, stats.longestStreak);
      expect(fromJson.dailyStats.length, stats.dailyStats.length);
    });
  });
}
