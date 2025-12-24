import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/models/achievement.dart';

void main() {
  group('Achievement Model Tests', () {
    test('Create achievement with required fields', () {
      final achievement = Achievement(
        id: 'test_achievement',
        title: 'Test Achievement',
        description: 'Test Description',
        icon: '🏆',
        category: AchievementCategory.pomodoro,
        targetValue: 10,
      );

      expect(achievement.id, 'test_achievement');
      expect(achievement.title, 'Test Achievement');
      expect(achievement.description, 'Test Description');
      expect(achievement.icon, '🏆');
      expect(achievement.category, AchievementCategory.pomodoro);
      expect(achievement.targetValue, 10);
      expect(achievement.isUnlocked, false);
      expect(achievement.unlockedAt, null);
    });

    test('Calculate progress correctly', () {
      final achievement = Achievement(
        id: 'test',
        title: 'Test',
        description: 'Test',
        icon: '🏆',
        category: AchievementCategory.pomodoro,
        targetValue: 100,
      );

      expect(achievement.getProgress(0), 0.0);
      expect(achievement.getProgress(50), 0.5);
      expect(achievement.getProgress(100), 1.0);
      expect(achievement.getProgress(150), 1.0); 
    });

    test('toJson and fromJson work correctly', () {
      final achievement = Achievement(
        id: 'test',
        title: 'Test Achievement',
        description: 'Description',
        icon: '🎯',
        category: AchievementCategory.streak,
        targetValue: 7,
        isUnlocked: true,
        unlockedAt: DateTime(2025, 12, 24),
      );

      final json = achievement.toJson();
      final fromJson = Achievement.fromJson(json);

      expect(fromJson.id, achievement.id);
      expect(fromJson.title, achievement.title);
      expect(fromJson.description, achievement.description);
      expect(fromJson.icon, achievement.icon);
      expect(fromJson.category, achievement.category);
      expect(fromJson.targetValue, achievement.targetValue);
      expect(fromJson.isUnlocked, achievement.isUnlocked);
      expect(fromJson.unlockedAt, achievement.unlockedAt);
    });

    test('copyWith creates new instance with updated values', () {
      final original = Achievement(
        id: 'test',
        title: 'Original',
        description: 'Description',
        icon: '🏆',
        category: AchievementCategory.pomodoro,
        targetValue: 10,
      );

      final updated = original.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime(2025, 12, 24),
      );

      expect(updated.id, original.id);
      expect(updated.isUnlocked, true);
      expect(updated.unlockedAt, DateTime(2025, 12, 24));
      expect(original.isUnlocked, false); 
    });

    test('DefaultAchievements returns all achievements', () {
      final achievements = DefaultAchievements.getAll();

      expect(achievements.isNotEmpty, true);
      expect(
        achievements.length,
        greaterThan(15),
      ); 

      expect(achievements.any((a) => a.id == 'first_pomodoro'), true);
      expect(achievements.any((a) => a.id == 'streak_7'), true);
      expect(achievements.any((a) => a.id == 'time_100h'), true);
    });

    test('Achievement categories are properly set', () {
      final achievements = DefaultAchievements.getAll();

      final pomodoroAchievements = achievements
          .where((a) => a.category == AchievementCategory.pomodoro)
          .toList();
      final streakAchievements = achievements
          .where((a) => a.category == AchievementCategory.streak)
          .toList();
      final timeAchievements = achievements
          .where((a) => a.category == AchievementCategory.time)
          .toList();
      final specialAchievements = achievements
          .where((a) => a.category == AchievementCategory.special)
          .toList();

      expect(pomodoroAchievements.isNotEmpty, true);
      expect(streakAchievements.isNotEmpty, true);
      expect(timeAchievements.isNotEmpty, true);
      expect(specialAchievements.isNotEmpty, true);
    });
  });
}
