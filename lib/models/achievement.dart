class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final int targetValue;
  final DateTime? unlockedAt;
  bool isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    AchievementCategory? category,
    int? targetValue,
    DateTime? unlockedAt,
    bool? isUnlocked,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'category': category.toString(),
      'targetValue': targetValue,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      category: AchievementCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => AchievementCategory.general,
      ),
      targetValue: json['targetValue'] as int,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  double getProgress(int currentValue) {
    if (targetValue == 0) return 0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }
}

enum AchievementCategory {
  general,    // Thành tích chung
  pomodoro,   // Liên quan đến số Pomodoro
  streak,     // Liên quan đến streak
  time,       // Liên quan đến thời gian học
  special,    // Thành tích đặc biệt
}

// Danh sách achievements mặc định
class DefaultAchievements {
  static List<Achievement> getAll() {
    return [
      // POMODORO ACHIEVEMENTS
      Achievement(
        id: 'first_pomodoro',
        title: 'Bắt đầu hành trình',
        description: 'Hoàn thành Pomodoro đầu tiên',
        icon: '🌱',
        category: AchievementCategory.pomodoro,
        targetValue: 1,
      ),
      Achievement(
        id: 'pomodoro_10',
        title: 'Người mới',
        description: 'Hoàn thành 10 Pomodoro',
        icon: '🌿',
        category: AchievementCategory.pomodoro,
        targetValue: 10,
      ),
      Achievement(
        id: 'pomodoro_50',
        title: 'Học viên chăm chỉ',
        description: 'Hoàn thành 50 Pomodoro',
        icon: '🌳',
        category: AchievementCategory.pomodoro,
        targetValue: 50,
      ),
      Achievement(
        id: 'pomodoro_100',
        title: 'Người kiên định',
        description: 'Hoàn thành 100 Pomodoro',
        icon: '🏆',
        category: AchievementCategory.pomodoro,
        targetValue: 100,
      ),
      Achievement(
        id: 'pomodoro_250',
        title: 'Chuyên gia',
        description: 'Hoàn thành 250 Pomodoro',
        icon: '🎖️',
        category: AchievementCategory.pomodoro,
        targetValue: 250,
      ),
      Achievement(
        id: 'pomodoro_500',
        title: 'Bậc thầy',
        description: 'Hoàn thành 500 Pomodoro',
        icon: '👑',
        category: AchievementCategory.pomodoro,
        targetValue: 500,
      ),
      Achievement(
        id: 'pomodoro_1000',
        title: 'Huyền thoại',
        description: 'Hoàn thành 1000 Pomodoro',
        icon: '⭐',
        category: AchievementCategory.pomodoro,
        targetValue: 1000,
      ),

      // STREAK ACHIEVEMENTS
      Achievement(
        id: 'streak_3',
        title: 'Khởi đầu tốt',
        description: 'Học liên tục 3 ngày',
        icon: '🔥',
        category: AchievementCategory.streak,
        targetValue: 3,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Tuần hoàn hảo',
        description: 'Học liên tục 7 ngày',
        icon: '💪',
        category: AchievementCategory.streak,
        targetValue: 7,
      ),
      Achievement(
        id: 'streak_14',
        title: 'Hai tuần không nghỉ',
        description: 'Học liên tục 14 ngày',
        icon: '🚀',
        category: AchievementCategory.streak,
        targetValue: 14,
      ),
      Achievement(
        id: 'streak_30',
        title: 'Tháng kiên trì',
        description: 'Học liên tục 30 ngày',
        icon: '🌟',
        category: AchievementCategory.streak,
        targetValue: 30,
      ),
      Achievement(
        id: 'streak_100',
        title: 'Kỷ lục vàng',
        description: 'Học liên tục 100 ngày',
        icon: '🥇',
        category: AchievementCategory.streak,
        targetValue: 100,
      ),

      // TIME ACHIEVEMENTS
      Achievement(
        id: 'time_10h',
        title: 'Mốc đầu tiên',
        description: 'Học được 10 giờ',
        icon: '⏰',
        category: AchievementCategory.time,
        targetValue: 600, // 10 giờ = 600 phút
      ),
      Achievement(
        id: 'time_50h',
        title: 'Nửa trăm giờ',
        description: 'Học được 50 giờ',
        icon: '⏱️',
        category: AchievementCategory.time,
        targetValue: 3000,
      ),
      Achievement(
        id: 'time_100h',
        title: 'Trăm giờ bay',
        description: 'Học được 100 giờ',
        icon: '🕐',
        category: AchievementCategory.time,
        targetValue: 6000,
      ),
      Achievement(
        id: 'time_250h',
        title: 'Chuyên nghiệp',
        description: 'Học được 250 giờ',
        icon: '📚',
        category: AchievementCategory.time,
        targetValue: 15000,
      ),
      Achievement(
        id: 'time_500h',
        title: 'Tiến sĩ thời gian',
        description: 'Học được 500 giờ',
        icon: '🎓',
        category: AchievementCategory.time,
        targetValue: 30000,
      ),

      // SPECIAL ACHIEVEMENTS
      Achievement(
        id: 'early_bird',
        title: 'Chim sớm',
        description: 'Học trước 6h sáng',
        icon: '🌅',
        category: AchievementCategory.special,
        targetValue: 1,
      ),
      Achievement(
        id: 'night_owl',
        title: 'Cú đêm',
        description: 'Học sau 10h đêm',
        icon: '🦉',
        category: AchievementCategory.special,
        targetValue: 1,
      ),
      Achievement(
        id: 'marathon',
        title: 'Marathon học tập',
        description: 'Hoàn thành 8 Pomodoro trong 1 ngày',
        icon: '🏃',
        category: AchievementCategory.special,
        targetValue: 8,
      ),
      Achievement(
        id: 'weekend_warrior',
        title: 'Chiến binh cuối tuần',
        description: 'Học cả thứ 7 và chủ nhật',
        icon: '⚔️',
        category: AchievementCategory.special,
        targetValue: 2,
      ),
    ];
  }
}
