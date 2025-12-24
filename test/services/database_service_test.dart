import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/services/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseService Tests', () {
    late DatabaseService dbService;

    setUp(() {
      dbService = DatabaseService();
    });

    test('Initialize database successfully', () async {
      final db = await dbService.database;
      expect(db, isNotNull);
      expect(db.isOpen, true);
    });

    test('Database has all required tables', () async {
      final db = await dbService.database;
      
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      
      final tableNames = tables.map((t) => t['name']).toList();
      
      expect(tableNames, contains('tasks'));
      expect(tableNames, contains('sessions'));
      expect(tableNames, contains('daily_stats'));
      expect(tableNames, contains('daily_stats_sessions'));
      expect(tableNames, contains('streak_info'));
      expect(tableNames, contains('app_settings'));
    });

    test('Tasks table has correct schema', () async {
      final db = await dbService.database;
      
      final columns = await db.rawQuery('PRAGMA table_info(tasks)');
      final columnNames = columns.map((c) => c['name']).toList();
      
      expect(columnNames, contains('id'));
      expect(columnNames, contains('title'));
      expect(columnNames, contains('completed'));
      expect(columnNames, contains('created_at'));
    });

    test('Sessions table has correct schema', () async {
      final db = await dbService.database;
      
      final columns = await db.rawQuery('PRAGMA table_info(sessions)');
      final columnNames = columns.map((c) => c['name']).toList();
      
      expect(columnNames, contains('id'));
      expect(columnNames, contains('theme_id'));
      expect(columnNames, contains('start_time'));
      expect(columnNames, contains('end_time'));
      expect(columnNames, contains('study_duration'));
      expect(columnNames, contains('break_duration'));
      expect(columnNames, contains('status'));
    });

    test('Streak info initializes with default values', () async {
      final db = await dbService.database;
      
      final result = await db.query('streak_info');
      
      expect(result.length, 1);
      expect(result.first['current_streak'], 0);
      expect(result.first['longest_streak'], 0);
    });

    test('Can insert and query data', () async {
      final db = await dbService.database;
      
      final testId = 'test_task_${DateTime.now().millisecondsSinceEpoch}';
      
      await db.insert('tasks', {
        'id': testId,
        'title': 'Test Task',
        'completed': 0,
        'pomodoros_completed': 0,
        'study_minutes': 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
      
      final result = await db.query('tasks', where: 'id = ?', whereArgs: [testId]);
      
      expect(result.length, 1);
      expect(result.first['title'], 'Test Task');
    });
  });
}
