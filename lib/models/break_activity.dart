import 'package:flutter/material.dart';

enum ActivityCategory {
  physical, // Vận động thể chất
  mental, // Tinh thần, thư giãn
  social, // Tương tác xã hội
  creative, // Sáng tạo
}

class BreakActivity {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final int durationMinutes; // Thời gian gợi ý (phút)
  final ActivityCategory category;

  BreakActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.durationMinutes,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon.codePoint,
      'durationMinutes': durationMinutes,
      'category': category.index,
    };
  }

  factory BreakActivity.fromJson(Map<String, dynamic> json) {
    return BreakActivity(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      durationMinutes: json['durationMinutes'],
      category: ActivityCategory.values[json['category']],
    );
  }

  String getCategoryName() {
    switch (category) {
      case ActivityCategory.physical:
        return 'Vận động';
      case ActivityCategory.mental:
        return 'Thư giãn';
      case ActivityCategory.social:
        return 'Xã hội';
      case ActivityCategory.creative:
        return 'Sáng tạo';
    }
  }

  Color getCategoryColor() {
    switch (category) {
      case ActivityCategory.physical:
        return Colors.green;
      case ActivityCategory.mental:
        return Colors.blue;
      case ActivityCategory.social:
        return Colors.orange;
      case ActivityCategory.creative:
        return Colors.purple;
    }
  }
}

// Lịch sử hoạt động đã thực hiện
class ActivityHistory {
  final String activityId;
  final DateTime completedAt;

  ActivityHistory({
    required this.activityId,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'activityId': activityId,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory ActivityHistory.fromJson(Map<String, dynamic> json) {
    return ActivityHistory(
      activityId: json['activityId'],
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}

// Danh sách hoạt động mặc định
class DefaultActivities {
  static List<BreakActivity> getAll() {
    return [
      // PHYSICAL - Vận động thể chất
      BreakActivity(
        id: 'stretch',
        name: 'Giãn cơ',
        description: 'Giãn cơ cổ, vai, lưng để giảm căng thẳng cơ bắp',
        icon: Icons.accessibility_new,
        durationMinutes: 5,
        category: ActivityCategory.physical,
      ),
      BreakActivity(
        id: 'walk',
        name: 'Đi bộ',
        description: 'Đi bộ nhẹ nhàng quanh phòng hoặc ra ngoài',
        icon: Icons.directions_walk,
        durationMinutes: 5,
        category: ActivityCategory.physical,
      ),
      BreakActivity(
        id: 'exercise',
        name: 'Tập thể dục',
        description: 'Chống đẩy, gập bụng, hoặc squat nhẹ',
        icon: Icons.fitness_center,
        durationMinutes: 10,
        category: ActivityCategory.physical,
      ),
      BreakActivity(
        id: 'yoga',
        name: 'Yoga',
        description: 'Thực hiện các tư thế yoga đơn giản',
        icon: Icons.self_improvement,
        durationMinutes: 10,
        category: ActivityCategory.physical,
      ),
      BreakActivity(
        id: 'eye_exercise',
        name: 'Thư giãn mắt',
        description: 'Nhìn xa, xoa bóp quanh mắt, nghỉ mắt',
        icon: Icons.visibility,
        durationMinutes: 3,
        category: ActivityCategory.physical,
      ),
      BreakActivity(
        id: 'quick_stretch',
        name: 'Duỗi người nhanh',
        description: 'Đứng lên, duỗi tay, xoay cổ',
        icon: Icons.accessibility,
        durationMinutes: 1,
        category: ActivityCategory.physical,
      ),

      // MENTAL - Thư giãn tinh thần
      BreakActivity(
        id: 'meditation',
        name: 'Thiền',
        description: 'Ngồi yên, tập trung vào hơi thở',
        icon: Icons.spa,
        durationMinutes: 5,
        category: ActivityCategory.mental,
      ),
      BreakActivity(
        id: 'breathing',
        name: 'Hít thở sâu',
        description: 'Thực hiện các bài tập hơi thở sâu',
        icon: Icons.air,
        durationMinutes: 3,
        category: ActivityCategory.mental,
      ),
      BreakActivity(
        id: 'relax_minute',
        name: 'Thư giãn 1 phút',
        description: 'Nhắm mắt, thả lỏng toàn thân',
        icon: Icons.self_improvement,
        durationMinutes: 1,
        category: ActivityCategory.mental,
      ),
      BreakActivity(
        id: 'music',
        name: 'Nghe nhạc',
        description: 'Nghe bài hát yêu thích để thư giãn',
        icon: Icons.music_note,
        durationMinutes: 5,
        category: ActivityCategory.mental,
      ),
      BreakActivity(
        id: 'nature',
        name: 'Ngắm thiên nhiên',
        description: 'Nhìn cây cối, bầu trời, hoặc cảnh quan',
        icon: Icons.nature,
        durationMinutes: 5,
        category: ActivityCategory.mental,
      ),
      BreakActivity(
        id: 'tea',
        name: 'Uống trà/cà phê',
        description: 'Thưởng thức đồ uống và thư giãn',
        icon: Icons.coffee,
        durationMinutes: 5,
        category: ActivityCategory.mental,
      ),

      // SOCIAL - Tương tác xã hội
      BreakActivity(
        id: 'chat',
        name: 'Trò chuyện',
        description: 'Nói chuyện với bạn bè hoặc gia đình',
        icon: Icons.chat,
        durationMinutes: 5,
        category: ActivityCategory.social,
      ),
      BreakActivity(
        id: 'quick_message',
        name: 'Nhắn tin nhanh',
        description: 'Gửi tin nhắn hỏi thăm ai đó',
        icon: Icons.message,
        durationMinutes: 1,
        category: ActivityCategory.social,
      ),
      BreakActivity(
        id: 'call',
        name: 'Gọi điện',
        description: 'Gọi điện cho người thân',
        icon: Icons.phone,
        durationMinutes: 5,
        category: ActivityCategory.social,
      ),
      BreakActivity(
        id: 'pet',
        name: 'Chơi với thú cưng',
        description: 'Dành thời gian với thú cưng của bạn',
        icon: Icons.pets,
        durationMinutes: 5,
        category: ActivityCategory.social,
      ),

      // CREATIVE - Sáng tạo
      BreakActivity(
        id: 'draw',
        name: 'Vẽ doodle',
        description: 'Vẽ vời tự do, không cần hoàn hảo',
        icon: Icons.brush,
        durationMinutes: 5,
        category: ActivityCategory.creative,
      ),
      BreakActivity(
        id: 'quick_sketch',
        name: 'Phác thảo nhanh',
        description: 'Vẽ 1 hình đơn giản bất kỳ',
        icon: Icons.draw,
        durationMinutes: 1,
        category: ActivityCategory.creative,
      ),
      BreakActivity(
        id: 'journal',
        name: 'Viết nhật ký',
        description: 'Ghi lại suy nghĩ hoặc cảm xúc',
        icon: Icons.edit_note,
        durationMinutes: 5,
        category: ActivityCategory.creative,
      ),
      BreakActivity(
        id: 'read',
        name: 'Đọc sách',
        description: 'Đọc vài trang sách yêu thích',
        icon: Icons.book,
        durationMinutes: 10,
        category: ActivityCategory.creative,
      ),
    ];
  }
}
