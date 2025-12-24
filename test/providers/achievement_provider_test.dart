import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/providers/achievement_provider.dart';
import 'package:promodo_study/models/achievement.dart';
import 'package:promodo_study/core/interfaces.dart';

@GenerateMocks([IAchievementRepository])
import 'achievement_provider_test.mocks.dart';

void main() {
  group('AchievementProvider Tests', () {
    late AchievementProvider provider;
    late MockIAchievementRepository mockRepository;

    setUp(() {
      mockRepository = MockIAchievementRepository();
      when(mockRepository.init()).thenAnswer((_) async {});
      when(mockRepository.loadAchievements()).thenAnswer((_) async => []);
      when(mockRepository.saveAchievements(any)).thenAnswer((_) async {});
      
      provider = AchievementProvider(mockRepository);
    });

    test('Initialize loads achievements from repository', () async {
      final achievementsData = [
        {
          'id': '1',
          'title': 'First Steps',
          'description': 'Complete your first pomodoro',
          'category': 'AchievementCategory.pomodoro',
          'targetValue': 1,
          'currentValue': 0,
          'isUnlocked': false,
        },
        {
          'id': '2',
          'title': 'Dedicated',
          'description': 'Complete 10 pomodoros',
          'category': 'AchievementCategory.pomodoro',
          'targetValue': 10,
          'currentValue': 10,
          'isUnlocked': true,
          'unlockedAt': DateTime.now().toIso8601String(),
        },
      ];

      when(mockRepository.loadAchievements())
          .thenAnswer((_) async => achievementsData);

      await provider.init();

      expect(provider.achievements.length, 2);
      expect(provider.unlockedAchievements.length, 1);
      expect(provider.lockedAchievements.length, 1);
      expect(provider.totalAchievements, 2);
      expect(provider.unlockedCount, 1);
      expect(provider.completionPercentage, 0.5);
      verify(mockRepository.loadAchievements()).called(1);
    });

    test('Initialize with empty repository uses defaults', () async {
      await provider.init();

      expect(provider.achievements.length, greaterThan(0));
      verify(mockRepository.saveAchievements(any)).called(1);
    });

    test('Unlock achievement', () async {
      await provider.init();

      final achievementId = provider.achievements.first.id;
      await provider.unlockAchievement(achievementId);

      final achievement = provider.getAchievementById(achievementId);
      expect(achievement?.isUnlocked, true);
      expect(achievement?.unlockedAt, isNotNull);
      verify(mockRepository.saveAchievements(any)).called(greaterThan(1));
    });

    test('Unlock already unlocked achievement does nothing', () async {
      await provider.init();

      final achievementId = provider.achievements.first.id;
      await provider.unlockAchievement(achievementId);
      
      final saveCallsBefore = verify(mockRepository.saveAchievements(any)).callCount;
      await provider.unlockAchievement(achievementId); // Try again
      final saveCallsAfter = verify(mockRepository.saveAchievements(any)).callCount;

      expect(saveCallsAfter, saveCallsBefore); // No additional save
    });

    test('Check and unlock pomodoro achievement', () async {
      await provider.init();

      await provider.checkAndUnlockAchievements(
        totalPomodoros: 1,
        currentStreak: 0,
        totalStudyMinutes: 0,
        todayPomodoros: 0,
      );

      final pomodoroAchievements = provider.getAchievementsByCategory(
        AchievementCategory.pomodoro,
      );
      final firstAchievement = pomodoroAchievements.firstWhere(
        (a) => a.targetValue == 1,
      );

      expect(firstAchievement.isUnlocked, true);
    });

    test('Check and unlock streak achievement', () async {
      await provider.init();

      await provider.checkAndUnlockAchievements(
        totalPomodoros: 0,
        currentStreak: 3,
        totalStudyMinutes: 0,
        todayPomodoros: 0,
      );

      final streakAchievements = provider.getAchievementsByCategory(
        AchievementCategory.streak,
      );
      final threeDay = streakAchievements.firstWhere(
        (a) => a.targetValue == 3,
        orElse: () => streakAchievements.first,
      );

      if (threeDay.targetValue == 3) {
        expect(threeDay.isUnlocked, true);
      }
    });

    test('Check and unlock time achievement', () async {
      await provider.init();

      await provider.checkAndUnlockAchievements(
        totalPomodoros: 0,
        currentStreak: 0,
        totalStudyMinutes: 60,
        todayPomodoros: 0,
      );

      final timeAchievements = provider.getAchievementsByCategory(
        AchievementCategory.time,
      );
      final oneHour = timeAchievements.firstWhere(
        (a) => a.targetValue == 60,
        orElse: () => timeAchievements.first,
      );

      if (oneHour.targetValue == 60) {
        expect(oneHour.isUnlocked, true);
      }
    });

    test('Recently unlocked achievements', () async {
      await provider.init();

      final achievementId = provider.achievements.first.id;
      await provider.unlockAchievement(achievementId);

      expect(provider.recentlyUnlocked.length, 1);
      expect(provider.recentlyUnlocked.first.id, achievementId);

      provider.clearRecentlyUnlocked();
      expect(provider.recentlyUnlocked.length, 0);
    });

    test('Achievement unlock callback', () async {
      await provider.init();
      Achievement? unlockedAchievement;
      
      provider.onAchievementUnlocked = (achievement) {
        unlockedAchievement = achievement;
      };

      final achievementId = provider.achievements.first.id;
      await provider.unlockAchievement(achievementId);

      expect(unlockedAchievement, isNotNull);
      expect(unlockedAchievement?.id, achievementId);
    });

    test('Get achievements by category', () async {
      await provider.init();

      final pomodoroAchievements = provider.getAchievementsByCategory(
        AchievementCategory.pomodoro,
      );
      final streakAchievements = provider.getAchievementsByCategory(
        AchievementCategory.streak,
      );

      expect(pomodoroAchievements.length, greaterThan(0));
      expect(streakAchievements.length, greaterThan(0));
      expect(
        pomodoroAchievements.every((a) => a.category == AchievementCategory.pomodoro),
        true,
      );
    });

    test('Reset all achievements', () async {
      await provider.init();

      // Unlock some achievements
      for (var achievement in provider.achievements.take(3)) {
        await provider.unlockAchievement(achievement.id);
      }

      expect(provider.unlockedCount, greaterThan(0));

      await provider.resetAllAchievements();

      expect(provider.unlockedCount, 0);
      expect(
        provider.achievements.every((a) => !a.isUnlocked && a.unlockedAt == null),
        true,
      );
    });

    test('Get achievement by id', () async {
      await provider.init();

      final firstId = provider.achievements.first.id;
      final achievement = provider.getAchievementById(firstId);

      expect(achievement, isNotNull);
      expect(achievement?.id, firstId);

      final nonExistent = provider.getAchievementById('non-existent-id');
      expect(nonExistent, null);
    });
  });
}
