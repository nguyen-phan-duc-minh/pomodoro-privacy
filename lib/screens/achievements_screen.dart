import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/statistics_provider.dart';
import '../models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Huy hiệu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<AchievementProvider, StatisticsProvider>(
        builder: (context, achievementProvider, statsProvider, _) {
          final totalPomodoros = _getTotalPomodoros(statsProvider);
          final currentStreak = statsProvider.currentStreak;
          final totalStudyMinutes = statsProvider.getTotalStudyMinutes();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ..._buildAchievementsByCategory(
                context,
                achievementProvider,
                totalPomodoros,
                currentStreak,
                totalStudyMinutes,
              ),
            ],
          );
        },
      ),
    );
  }

  int _getTotalPomodoros(StatisticsProvider statsProvider) {
    int total = 0;
    for (var stats in statsProvider.statistics.dailyStats.values) {
      total += stats.completedCycles;
    }
    return total;
  }

  List<Widget> _buildAchievementsByCategory(
    BuildContext context,
    AchievementProvider provider,
    int totalPomodoros,
    int currentStreak,
    int totalStudyMinutes,
  ) {
    final categories = [
      AchievementCategory.pomodoro,
      AchievementCategory.streak,
      AchievementCategory.time,
      AchievementCategory.special,
    ];

    return categories.map((category) {
      final categoryAchievements = provider.getAchievementsByCategory(category);
      if (categoryAchievements.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _getCategoryName(category),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...categoryAchievements.map((achievement) {
            int currentValue = 0;
            switch (category) {
              case AchievementCategory.pomodoro:
                currentValue = totalPomodoros;
                break;
              case AchievementCategory.streak:
                currentValue = currentStreak;
                break;
              case AchievementCategory.time:
                currentValue = totalStudyMinutes;
                break;
              case AchievementCategory.special:
                currentValue = 0; 
                break;
              case AchievementCategory.general:
                currentValue = 0;
                break;
            }

            return _AchievementCard(
              achievement: achievement,
              currentValue: currentValue,
            );
          }),
          const SizedBox(height: 6),
        ],
      );
    }).toList();
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.pomodoro:
        return 'Pomodoro';
      case AchievementCategory.streak:
        return 'Streak';
      case AchievementCategory.time:
        return 'Thời gian';
      case AchievementCategory.special:
        return 'Đặc biệt';
      case AchievementCategory.general:
        return 'Chung';
    }
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final int currentValue;

  const _AchievementCard({
    required this.achievement,
    required this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final progress = achievement.getProgress(currentValue);
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? const Color(0xFFFFD700) 
                    : const Color(0xFF9E9E9E), 
                shape: BoxShape.circle,
                boxShadow: isUnlocked
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.6),
                          blurRadius: 15,
                          spreadRadius: 4,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: isUnlocked
                    ? Text(
                        achievement.icon,
                        style: const TextStyle(
                          fontSize: 32,
                        ),
                      )
                    : Opacity(
                        opacity: 0.25,
                        child: Text(
                          achievement.icon,
                          style: const TextStyle(
                            fontSize: 32,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? null : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (!isUnlocked &&
                      achievement.category != AchievementCategory.special) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentValue / ${achievement.targetValue}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  if (isUnlocked && achievement.unlockedAt != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Đã mở khóa',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
