import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/services/database_service.dart';
import 'package:promodo_study/core/repositories_sqlite.dart';
import 'package:promodo_study/models/goal.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@GenerateMocks([DatabaseService])
import 'goal_repository_test.mocks.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('GoalRepositorySQLite Tests', () {
    late GoalRepositorySQLite repository;
    late Database testDb;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE goals (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              type TEXT NOT NULL,
              target_minutes INTEGER NOT NULL,
              created_at INTEGER NOT NULL,
              completed_at INTEGER,
              is_active INTEGER NOT NULL DEFAULT 1
            )
          ''');
          await db.execute('CREATE INDEX idx_goals_is_active ON goals(is_active)');
          await db.execute('CREATE INDEX idx_goals_type ON goals(type)');
        },
      );

      final mockDbService = MockDatabaseService();
      when(mockDbService.database).thenAnswer((_) async => testDb);

      repository = GoalRepositorySQLite(mockDbService);
      await repository.init();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Save and load goals correctly', () async {
      final goals = [
        Goal(
          id: '1',
          title: 'Daily Goal',
          type: GoalType.daily,
          targetMinutes: 60,
          createdAt: DateTime(2025, 12, 24),
        ),
        Goal(
          id: '2',
          title: 'Weekly Goal',
          type: GoalType.weekly,
          targetMinutes: 300,
          createdAt: DateTime(2025, 12, 20),
          completedAt: DateTime(2025, 12, 24),
          isActive: false,
        ),
      ];

      await repository.saveGoals(goals);
      final loaded = await repository.loadGoals();

      expect(loaded.length, 2);
      
      final goal1 = Goal.fromJson(loaded[0] as Map<String, dynamic>);
      expect(goal1.id, '1');
      expect(goal1.title, 'Daily Goal');
      expect(goal1.type, GoalType.daily);
      expect(goal1.targetMinutes, 60);
      expect(goal1.isActive, true);
      
      final goal2 = Goal.fromJson(loaded[1] as Map<String, dynamic>);
      expect(goal2.id, '2');
      expect(goal2.isActive, false);
      expect(goal2.completedAt, isNotNull);
    });

    test('Load goals returns empty list when no goals exist', () async {
      final loaded = await repository.loadGoals();
      expect(loaded, isEmpty);
    });

    test('Save goals replaces existing goals', () async {
      final goals1 = [
        Goal(
          id: '1',
          title: 'Goal 1',
          type: GoalType.daily,
          targetMinutes: 60,
          createdAt: DateTime.now(),
        ),
      ];

      await repository.saveGoals(goals1);
      var loaded = await repository.loadGoals();
      expect(loaded.length, 1);

      final goals2 = [
        Goal(
          id: '2',
          title: 'Goal 2',
          type: GoalType.weekly,
          targetMinutes: 300,
          createdAt: DateTime.now(),
        ),
        Goal(
          id: '3',
          title: 'Goal 3',
          type: GoalType.monthly,
          targetMinutes: 1200,
          createdAt: DateTime.now(),
        ),
      ];

      await repository.saveGoals(goals2);
      loaded = await repository.loadGoals();
      expect(loaded.length, 2);
      
      final goal = Goal.fromJson(loaded[0] as Map<String, dynamic>);
      expect(goal.id, '2');
    });

    test('Goals are ordered by created_at DESC', () async {
      final goals = [
        Goal(
          id: '1',
          title: 'Old Goal',
          type: GoalType.daily,
          targetMinutes: 60,
          createdAt: DateTime(2025, 12, 20),
        ),
        Goal(
          id: '2',
          title: 'New Goal',
          type: GoalType.daily,
          targetMinutes: 60,
          createdAt: DateTime(2025, 12, 24),
        ),
      ];

      await repository.saveGoals(goals);
      final loaded = await repository.loadGoals();

      final firstGoal = Goal.fromJson(loaded[0] as Map<String, dynamic>);
      expect(firstGoal.id, '2'); // Newest first
    });

    test('Goal type is preserved', () async {
      for (var type in GoalType.values) {
        final goals = [
          Goal(
            id: type.toString(),
            title: 'Test ${type.toString()}',
            type: type,
            targetMinutes: 60,
            createdAt: DateTime.now(),
          ),
        ];

        await repository.saveGoals(goals);
        final loaded = await repository.loadGoals();
        
        final goal = Goal.fromJson(loaded[0] as Map<String, dynamic>);
        expect(goal.type, type);
      }
    });
  });
}
