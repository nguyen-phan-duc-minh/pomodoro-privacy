import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/services/database_service.dart';
import 'package:promodo_study/core/repositories_sqlite.dart';
import 'package:promodo_study/models/achievement.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@GenerateMocks([DatabaseService])
import 'achievement_repository_test.mocks.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AchievementRepositorySQLite Tests', () {
    late AchievementRepositorySQLite repository;
    late Database testDb;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE achievements (
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT NOT NULL,
              category TEXT NOT NULL,
              target_value INTEGER NOT NULL,
              current_value INTEGER NOT NULL DEFAULT 0,
              is_unlocked INTEGER NOT NULL DEFAULT 0,
              unlocked_at INTEGER
            )
          ''');
          await db.execute('CREATE INDEX idx_achievements_unlocked ON achievements(is_unlocked)');
        },
      );

      final mockDbService = MockDatabaseService();
      when(mockDbService.database).thenAnswer((_) async => testDb);

      repository = AchievementRepositorySQLite(mockDbService);
      await repository.init();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Save and load achievements correctly', () async {
      final achievements = [
        Achievement(
          id: 'first_steps',
          title: 'First Steps',
          description: 'Complete your first pomodoro',
          icon: '🏆',
          category: AchievementCategory.pomodoro,
          targetValue: 1,
        ),
        Achievement(
          id: 'dedicated',
          title: 'Dedicated',
          description: 'Complete 10 pomodoros',
          icon: '🎯',
          category: AchievementCategory.pomodoro,
          targetValue: 10,
          isUnlocked: true,
          unlockedAt: DateTime(2025, 12, 24),
        ),
      ];

      await repository.saveAchievements(achievements);
      final loaded = await repository.loadAchievements();

      expect(loaded.length, 2);
      
      final achievement1 = Achievement.fromJson(loaded[0] as Map<String, dynamic>);
      expect(achievement1.id, 'first_steps');
      expect(achievement1.title, 'First Steps');
      expect(achievement1.isUnlocked, false);
      expect(achievement1.targetValue, 1);
      
      final achievement2 = Achievement.fromJson(loaded[1] as Map<String, dynamic>);
      expect(achievement2.id, 'dedicated');
      expect(achievement2.isUnlocked, true);
      expect(achievement2.unlockedAt, isNotNull);
    });

    test('Load achievements returns empty list when no achievements exist', () async {
      final loaded = await repository.loadAchievements();
      expect(loaded, isEmpty);
    });

    test('Save achievements replaces existing achievements', () async {
      final achievements1 = [
        Achievement(
          id: '1',
          title: 'Achievement 1',
          description: 'Description 1',
          icon: '🏆',
          category: AchievementCategory.pomodoro,
          targetValue: 5,
        ),
      ];

      await repository.saveAchievements(achievements1);
      var loaded = await repository.loadAchievements();
      expect(loaded.length, 1);

      final achievements2 = [
        Achievement(
          id: '2',
          title: 'Achievement 2',
          description: 'Description 2',
          icon: '🎯',
          category: AchievementCategory.streak,
          targetValue: 7,
        ),
      ];

      await repository.saveAchievements(achievements2);
      loaded = await repository.loadAchievements();
      expect(loaded.length, 1);
      
      final achievement = Achievement.fromJson(loaded[0] as Map<String, dynamic>);
      expect(achievement.id, '2');
    });

    test('Achievement category is preserved', () async {
      for (var category in AchievementCategory.values) {
        final achievements = [
          Achievement(
            id: category.toString(),
            title: 'Test ${category.toString()}',
            description: 'Description',
            icon: '🏆',
            category: category,
            targetValue: 10,
          ),
        ];

        await repository.saveAchievements(achievements);
        final loaded = await repository.loadAchievements();
        
        final achievement = Achievement.fromJson(loaded[0] as Map<String, dynamic>);
        expect(achievement.category, category);
      }
    });

    test('Unlocked status is preserved correctly', () async {
      final achievements = [
        Achievement(
          id: 'unlocked',
          title: 'Unlocked Achievement',
          description: 'This is unlocked',
          icon: '🏆',
          category: AchievementCategory.pomodoro,
          targetValue: 5,
          isUnlocked: true,
          unlockedAt: DateTime(2025, 12, 24, 10, 30),
        ),
        Achievement(
          id: 'locked',
          title: 'Locked Achievement',
          description: 'This is locked',
          icon: '🎯',
          category: AchievementCategory.streak,
          targetValue: 10,
          isUnlocked: false,
        ),
      ];

      await repository.saveAchievements(achievements);
      final loaded = await repository.loadAchievements();

      expect(loaded.length, 2);
      
      final unlocked = Achievement.fromJson(
        loaded.firstWhere((a) => (a as Map)['id'] == 'unlocked') as Map<String, dynamic>,
      );
      expect(unlocked.isUnlocked, true);
      expect(unlocked.unlockedAt, isNotNull);
      
      final locked = Achievement.fromJson(
        loaded.firstWhere((a) => (a as Map)['id'] == 'locked') as Map<String, dynamic>,
      );
      expect(locked.isUnlocked, false);
      expect(locked.unlockedAt, null);
    });

    test('Target value is preserved', () async {
      final achievements = [
        Achievement(
          id: 'progress',
          title: 'In Progress',
          description: 'Making progress',
          icon: '🎯',
          category: AchievementCategory.time,
          targetValue: 100,
        ),
      ];

      await repository.saveAchievements(achievements);
      final loaded = await repository.loadAchievements();
      
      final achievement = Achievement.fromJson(loaded[0] as Map<String, dynamic>);
      expect(achievement.targetValue, 100);
    });
  });
}
