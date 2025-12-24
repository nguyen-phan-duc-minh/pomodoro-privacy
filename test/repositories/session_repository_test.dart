import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:promodo_study/core/repositories_sqlite.dart';
import 'package:promodo_study/models/pomodoro_session.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'task_repository_test.mocks.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('SessionRepositorySQLite Tests', () {
    late SessionRepositorySQLite repository;
    late Database testDb;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE sessions (
              id TEXT PRIMARY KEY,
              theme_id TEXT NOT NULL,
              start_time INTEGER NOT NULL,
              end_time INTEGER,
              study_duration INTEGER NOT NULL,
              break_duration INTEGER NOT NULL,
              total_study_time INTEGER NOT NULL DEFAULT 0,
              total_break_time INTEGER NOT NULL DEFAULT 0,
              completed_cycles INTEGER NOT NULL DEFAULT 0,
              target_cycles INTEGER NOT NULL DEFAULT 1,
              status TEXT NOT NULL,
              current_type TEXT NOT NULL
            )
          ''');
        },
      );

      final mockDbService = MockDatabaseService();
      when(mockDbService.database).thenAnswer((_) async => testDb);

      repository = SessionRepositorySQLite(mockDbService);
      await repository.init();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Save and load session correctly', () async {
      final session = PomodoroSession(
        id: 'session1',
        themeId: 'theme1',
        startTime: DateTime(2025, 12, 24, 10, 0),
        studyDuration: 1500,
        breakDuration: 300,
        status: SessionStatus.running,
        currentType: SessionType.study,
      );

      await repository.saveSession(session);
      final loaded = await repository.loadSession();

      expect(loaded, isNotNull);
      expect(loaded!.id, session.id);
      expect(loaded.themeId, session.themeId);
      expect(loaded.studyDuration, session.studyDuration);
      expect(loaded.status, session.status);
    });

    test('Load most recent non-completed session', () async {
      final session1 = PomodoroSession(
        id: 'session1',
        themeId: 'theme1',
        startTime: DateTime(2025, 12, 24, 9, 0),
        studyDuration: 1500,
        breakDuration: 300,
        status: SessionStatus.completed,
      );

      final session2 = PomodoroSession(
        id: 'session2',
        themeId: 'theme1',
        startTime: DateTime(2025, 12, 24, 10, 0),
        studyDuration: 1500,
        breakDuration: 300,
        status: SessionStatus.running,
      );

      await repository.saveSession(session1);
      await repository.saveSession(session2);

      final loaded = await repository.loadSession();
      expect(loaded!.id, 'session2'); // Should load the running one
    });

    test('Load session returns null when none exist', () async {
      final loaded = await repository.loadSession();
      expect(loaded, isNull);
    });

    test('Update existing session', () async {
      final session = PomodoroSession(
        id: 'session1',
        themeId: 'theme1',
        startTime: DateTime(2025, 12, 24, 10, 0),
        studyDuration: 1500,
        breakDuration: 300,
        elapsedStudyTime: 500,
        status: SessionStatus.running,
      );

      await repository.saveSession(session);

      final updated = session.copyWith(
        elapsedStudyTime: 1000,
        status: SessionStatus.paused,
      );

      await repository.saveSession(updated);
      final loaded = await repository.loadSession();

      expect(loaded!.elapsedStudyTime, 1000);
      expect(loaded.status, SessionStatus.paused);
    });

    test('Save session with all fields', () async {
      final session = PomodoroSession(
        id: 'session_full',
        themeId: 'theme1',
        startTime: DateTime(2025, 12, 24, 10, 0),
        endTime: DateTime(2025, 12, 24, 12, 0),
        studyDuration: 1500,
        breakDuration: 300,
        elapsedStudyTime: 1500,
        elapsedBreakTime: 300,
        completedCycles: 4,
        targetCycles: 4,
        status: SessionStatus.completed,
        currentType: SessionType.breakTime,
      );

      await repository.saveSession(session);
      final loaded = await repository.loadSession();

      // Completed sessions should not be loaded by loadSession
      expect(loaded, isNull);
    });
  });
}
