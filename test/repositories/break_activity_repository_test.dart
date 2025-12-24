import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/services/database_service.dart';
import 'package:promodo_study/core/repositories_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@GenerateMocks([DatabaseService])
import 'break_activity_repository_test.mocks.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('BreakActivityRepositorySQLite Tests', () {
    late BreakActivityRepositorySQLite repository;
    late Database testDb;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
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

      repository = BreakActivityRepositorySQLite(mockDbService);
      await repository.init();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Save and load selected activity correctly', () async {
      const activityId = 'stretch-001';

      await repository.saveSelectedActivity(activityId);
      final loaded = await repository.loadSelectedActivity();

      expect(loaded, activityId);
    });

    test('Load selected activity returns null when not set', () async {
      final loaded = await repository.loadSelectedActivity();
      expect(loaded, null);
    });

    test('Save null activity clears selection', () async {
      await repository.saveSelectedActivity('activity-1');
      var loaded = await repository.loadSelectedActivity();
      expect(loaded, 'activity-1');

      await repository.saveSelectedActivity(null);
      loaded = await repository.loadSelectedActivity();
      expect(loaded, null);
    });

    test('Save activity replaces existing activity', () async {
      await repository.saveSelectedActivity('activity-1');
      var loaded = await repository.loadSelectedActivity();
      expect(loaded, 'activity-1');

      await repository.saveSelectedActivity('activity-2');
      loaded = await repository.loadSelectedActivity();
      expect(loaded, 'activity-2');
    });

    test('Activity ID with special characters', () async {
      const specialId = 'activity_with-special.chars@123';

      await repository.saveSelectedActivity(specialId);
      final loaded = await repository.loadSelectedActivity();

      expect(loaded, specialId);
    });

    test('Empty string activity ID', () async {
      await repository.saveSelectedActivity('');
      final loaded = await repository.loadSelectedActivity();

      expect(loaded, '');
    });

    test('Very long activity ID', () async {
      final longId = 'a' * 1000;

      await repository.saveSelectedActivity(longId);
      final loaded = await repository.loadSelectedActivity();

      expect(loaded, longId);
    });

    test('Multiple save operations preserve last value', () async {
      final activities = ['activity-1', 'activity-2', 'activity-3', 'activity-4'];

      for (final activity in activities) {
        await repository.saveSelectedActivity(activity);
      }

      final loaded = await repository.loadSelectedActivity();
      expect(loaded, activities.last);
    });
  });
}
