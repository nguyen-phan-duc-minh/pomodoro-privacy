import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../core/interfaces.dart';

class AchievementProvider with ChangeNotifier {
  final IAchievementRepository _repository;
  List<Achievement> _achievements = [];
  List<Achievement> _recentlyUnlocked = [];

  AchievementProvider(this._repository);

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements =>
      _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements =>
      _achievements.where((a) => !a.isUnlocked).toList();
  List<Achievement> get recentlyUnlocked => _recentlyUnlocked;

  int get totalAchievements => _achievements.length;
  int get unlockedCount => unlockedAchievements.length;
  double get completionPercentage =>
      totalAchievements > 0 ? (unlockedCount / totalAchievements) : 0;

  Function(Achievement)? onAchievementUnlocked;

  Future<void> init() async {
    await _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final achievementsData = await _repository.loadAchievements();
    _achievements = achievementsData.map((json) => Achievement.fromJson(json as Map<String, dynamic>)).toList();
    
    if (_achievements.isEmpty) {
      _achievements = DefaultAchievements.getAll();
      await _saveAchievements();
    }

    notifyListeners();
  }

  Future<void> _saveAchievements() async {
    await _repository.saveAchievements(_achievements);
  }

  Future<void> checkAndUnlockAchievements({
    required int totalPomodoros,
    required int currentStreak,
    required int totalStudyMinutes,
    required int todayPomodoros,
    DateTime? lastStudyTime,
  }) async {
    _recentlyUnlocked.clear();

    for (var achievement in _achievements) {
      if (achievement.isUnlocked) continue;

      bool shouldUnlock = false;

      switch (achievement.category) {
        case AchievementCategory.pomodoro:
          shouldUnlock = totalPomodoros >= achievement.targetValue;
          break;

        case AchievementCategory.streak:
          shouldUnlock = currentStreak >= achievement.targetValue;
          break;

        case AchievementCategory.time:
          shouldUnlock = totalStudyMinutes >= achievement.targetValue;
          break;

        case AchievementCategory.special:
          if (achievement.id == 'early_bird' && lastStudyTime != null) {
            shouldUnlock = lastStudyTime.hour < 6;
          } else if (achievement.id == 'night_owl' && lastStudyTime != null) {
            shouldUnlock = lastStudyTime.hour >= 22;
          } else if (achievement.id == 'marathon') {
            shouldUnlock = todayPomodoros >= achievement.targetValue;
          } else if (achievement.id == 'weekend_warrior') {
            shouldUnlock = false;
          }
          break;

        case AchievementCategory.general:
          break;
      }

      if (shouldUnlock) {
        await unlockAchievement(achievement.id);
      }
    }

    notifyListeners();
  }

  Future<void> unlockAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index == -1) return;

    if (!_achievements[index].isUnlocked) {
      _achievements[index] = _achievements[index].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );

      _recentlyUnlocked.add(_achievements[index]);
      onAchievementUnlocked?.call(_achievements[index]);

      await _saveAchievements();
      notifyListeners();
    }
  }

  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
    notifyListeners();
  }

  List<Achievement> getAchievementsByCategory(AchievementCategory category) {
    return _achievements.where((a) => a.category == category).toList();
  }

  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> resetAllAchievements() async {
    for (var i = 0; i < _achievements.length; i++) {
      _achievements[i] = _achievements[i].copyWith(
        isUnlocked: false,
        unlockedAt: null,
      );
    }
    await _saveAchievements();
    notifyListeners();
  }
}
