import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:promodo_study/core/repositories_sqlite.dart';
import 'package:promodo_study/models/study_statistics.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'task_repository_test.mocks.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('StatisticsRepositorySQLite Tests', () {
    late StatisticsRepositorySQLite repository;
    late Database testDb;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE daily_stats (
              date TEXT PRIMARY KEY,
              total_study_minutes INTEGER NOT NULL DEFAULT 0,
              total_break_minutes INTEGER NOT NULL DEFAULT 0,
              completed_cycles INTEGER NOT NULL DEFAULT 0,
              session_count INTEGER NOT NULL DEFAULT 0
            )
          ''');

          await db.execute('''
            CREATE TABLE daily_stats_sessions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              date TEXT NOT NULL,
              session_id TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE streak_info (
              id INTEGER PRIMARY KEY CHECK (id = 1),
              current_streak INTEGER NOT NULL DEFAULT 0,
              longest_streak INTEGER NOT NULL DEFAULT 0,
              last_study_date TEXT
            )
          ''');

          await db.insert('streak_info', {
            'id': 1,
            'current_streak': 0,
            'longest_streak': 0,
            'last_study_date': null,
          });
        },
      );

      final mockDbService = MockDatabaseService();
      when(mockDbService.database).thenAnswer((_) async => testDb);

      repository = StatisticsRepositorySQLite(mockDbService);
      await repository.init();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Save and load statistics correctly', () async {
      final stats = StudyStatistics();
      final today = DateTime(2025, 12, 24);

      stats.addSession(
        date: today,
        studyMinutes: 50,
        breakMinutes: 10,
        cycles: 2,
        sessionId: 'session1',
      );

      await repository.saveStatistics(stats);
      final loaded = await repository.loadStatistics();

      expect(loaded, isNotNull);
      expect(loaded!.currentStreak, stats.currentStreak);
      expect(loaded.longestStreak, stats.longestStreak);
    });

    test('Save and load streak information', () async {
      final stats = StudyStatistics();
      final today = DateTime(2025, 12, 24);

      for (int i = 0; i < 7; i++) {
        stats.addSession(
          date: today.subtract(Duration(days: i)),
          studyMinutes: 25,
          breakMinutes: 5,
          cycles: 1,
          sessionId: 'session$i',
        );
      }

      await repository.saveStatistics(stats);
      final loaded = await repository.loadStatistics();

      expect(loaded!.currentStreak, greaterThan(0));
      expect(loaded.longestStreak, greaterThanOrEqualTo(loaded.currentStreak));
    });

    test('Load empty statistics returns default', () async {
      final loaded = await repository.loadStatistics();
      
      expect(loaded, isNotNull);
      expect(loaded!.currentStreak, 0);
      expect(loaded.longestStreak, 0);
      expect(loaded.dailyStats, isEmpty);
    });

    test('Save multiple daily stats', () async {
      final stats = StudyStatistics();
      
      for (int i = 0; i < 5; i++) {
        stats.addSession(
          date: DateTime(2025, 12, 20 + i),
          studyMinutes: 25,
          breakMinutes: 5,
          cycles: 1,
          sessionId: 'session$i',
        );
      }

      await repository.saveStatistics(stats);
      final loaded = await repository.loadStatistics();

      expect(loaded!.dailyStats.length, 5);
    });

    test('Update existing statistics', () async {
      final stats1 = StudyStatistics();
      stats1.addSession(
        date: DateTime(2025, 12, 24),
        studyMinutes: 25,
        breakMinutes: 5,
        cycles: 1,
        sessionId: 'session1',
      );

      await repository.saveStatistics(stats1);

      final stats2 = StudyStatistics();
      stats2.addSession(
        date: DateTime(2025, 12, 24),
        studyMinutes: 50,
        breakMinutes: 10,
        cycles: 2,
        sessionId: 'session2',
      );

      await repository.saveStatistics(stats2);
      final loaded = await repository.loadStatistics();

      final todayStats = loaded!.dailyStats.values.first;
      expect(todayStats.totalStudyMinutes, 50);
      expect(todayStats.completedCycles, 2);
    });
  });
}
