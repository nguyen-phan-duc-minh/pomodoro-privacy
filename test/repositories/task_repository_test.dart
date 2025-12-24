import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/services/database_service.dart';
import 'package:promodo_study/core/repositories_sqlite.dart';
import 'package:promodo_study/models/task.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@GenerateMocks([DatabaseService])
import 'task_repository_test.mocks.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('TaskRepositorySQLite Tests', () {
    late TaskRepositorySQLite repository;
    late Database testDb;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE tasks (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              completed INTEGER NOT NULL DEFAULT 0,
              pomodoros_completed INTEGER NOT NULL DEFAULT 0,
              study_minutes INTEGER NOT NULL DEFAULT 0,
              created_at INTEGER NOT NULL,
              completed_at INTEGER
            )
          ''');

          await db.execute('''
            CREATE TABLE app_settings (
              key TEXT PRIMARY KEY,
              value TEXT
            )
          ''');
        },
      );

      final mockDbService = MockDatabaseService();
      when(mockDbService.database).thenAnswer((_) async => testDb);

      repository = TaskRepositorySQLite(mockDbService);
      await repository.init();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Save and load tasks correctly', () async {
      final tasks = [
        Task(
          id: '1',
          title: 'Task 1',
          createdAt: DateTime(2025, 12, 24),
        ),
        Task(
          id: '2',
          title: 'Task 2',
          completed: true,
          completedAt: DateTime(2025, 12, 24, 15, 0),
          createdAt: DateTime(2025, 12, 23),
        ),
      ];

      await repository.saveTasks(tasks);
      final loaded = await repository.loadTasks();

      expect(loaded.length, 2);
      expect(loaded[0].id, '1');
      expect(loaded[1].id, '2');
      expect(loaded[1].completed, true);
    });

    test('Save and load active task ID', () async {
      await repository.saveActiveTaskId('task123');
      final loaded = await repository.loadActiveTaskId();

      expect(loaded, 'task123');
    });

    test('Load active task ID returns null when not set', () async {
      final loaded = await repository.loadActiveTaskId();
      expect(loaded, null);
    });

    test('Save empty string as active task ID returns null', () async {
      await repository.saveActiveTaskId('');
      final loaded = await repository.loadActiveTaskId();

      expect(loaded, null);
    });

    test('Update existing tasks', () async {
      final tasks = [
        Task(id: '1', title: 'Original', createdAt: DateTime.now()),
      ];
      await repository.saveTasks(tasks);

      final updated = [
        Task(
          id: '1',
          title: 'Updated',
          completed: true,
          createdAt: DateTime.now(),
        ),
      ];
      await repository.saveTasks(updated);

      final loaded = await repository.loadTasks();
      expect(loaded.length, 1);
      expect(loaded[0].title, 'Updated');
      expect(loaded[0].completed, true);
    });

    test('Tasks are loaded in descending order by created_at', () async {
      final now = DateTime.now();
      final tasks = [
        Task(id: '1', title: 'Old', createdAt: now.subtract(const Duration(days: 2))),
        Task(id: '2', title: 'New', createdAt: now),
        Task(id: '3', title: 'Middle', createdAt: now.subtract(const Duration(days: 1))),
      ];

      await repository.saveTasks(tasks);
      final loaded = await repository.loadTasks();

      expect(loaded[0].id, '2'); 
      expect(loaded[1].id, '3'); 
      expect(loaded[2].id, '1'); 
    });

    test('Save tasks with pomodoros and study minutes', () async {
      final tasks = [
        Task(
          id: '1',
          title: 'Task with progress',
          pomodorosCompleted: 10,
          studyMinutes: 250,
          createdAt: DateTime.now(),
        ),
      ];

      await repository.saveTasks(tasks);
      final loaded = await repository.loadTasks();

      expect(loaded[0].pomodorosCompleted, 10);
      expect(loaded[0].studyMinutes, 250);
    });

    test('Handle tasks with null completedAt', () async {
      final tasks = [
        Task(
          id: '1',
          title: 'Incomplete',
          completed: false,
          completedAt: null,
          createdAt: DateTime.now(),
        ),
      ];

      await repository.saveTasks(tasks);
      final loaded = await repository.loadTasks();

      expect(loaded[0].completed, false);
      expect(loaded[0].completedAt, null);
    });
  });
}
