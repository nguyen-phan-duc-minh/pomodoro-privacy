import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/models/goal.dart';

void main() {
  group('Goal Model Tests', () {
    test('Create goal with required fields', () {
      final goal = Goal(
        id: 'goal1',
        title: 'Study 2 hours daily',
        type: GoalType.daily,
        targetMinutes: 120,
        createdAt: DateTime(2025, 1, 1),
      );

      expect(goal.id, 'goal1');
      expect(goal.title, 'Study 2 hours daily');
      expect(goal.type, GoalType.daily);
      expect(goal.targetMinutes, 120);
      expect(goal.isActive, true);
      expect(goal.completedAt, null);
    });

    test('copyWith updates fields correctly', () {
      final goal = Goal(
        id: 'goal1',
        title: 'Original',
        type: GoalType.daily,
        targetMinutes: 120,
        createdAt: DateTime(2025, 1, 1),
      );

      final updated = goal.copyWith(
        title: 'Updated',
        targetMinutes: 180,
        isActive: false,
      );

      expect(updated.id, 'goal1');
      expect(updated.title, 'Updated');
      expect(updated.targetMinutes, 180);
      expect(updated.isActive, false);
    });

    test('toJson and fromJson work correctly', () {
      final goal = Goal(
        id: 'goal1',
        title: 'Test Goal',
        type: GoalType.weekly,
        targetMinutes: 600,
        createdAt: DateTime(2025, 1, 1),
        completedAt: DateTime(2025, 1, 7),
        isActive: false,
      );

      final json = goal.toJson();
      expect(json['id'], 'goal1');
      expect(json['title'], 'Test Goal');
      expect(json['targetMinutes'], 600);
      expect(json['isActive'], false);

      final restored = Goal.fromJson(json);
      expect(restored.id, goal.id);
      expect(restored.title, goal.title);
      expect(restored.type, goal.type);
      expect(restored.targetMinutes, goal.targetMinutes);
      expect(restored.isActive, goal.isActive);
      expect(restored.completedAt?.day, goal.completedAt?.day);
    });

    test('fromJson handles legacy targetPomodoros field', () {
      final json = {
        'id': 'goal1',
        'title': 'Legacy Goal',
        'type': GoalType.daily.toString(),
        'targetPomodoros': 4, // Should convert to 100 minutes (4 * 25)
        'createdAt': DateTime(2025, 1, 1).toIso8601String(),
        'isActive': true,
      };

      final goal = Goal.fromJson(json);
      expect(goal.targetMinutes, 100);
    });

    test('getProgress calculates correctly', () {
      final goal = Goal(
        id: 'goal1',
        title: 'Test',
        type: GoalType.daily,
        targetMinutes: 120,
        createdAt: DateTime.now(),
      );

      expect(goal.getProgress(0), 0.0);
      expect(goal.getProgress(60), 0.5);
      expect(goal.getProgress(120), 1.0);
      expect(goal.getProgress(150), 1.0); // Clamped at 1.0
    });

    test('isCompleted returns correct status', () {
      final goal = Goal(
        id: 'goal1',
        title: 'Test',
        type: GoalType.daily,
        targetMinutes: 120,
        createdAt: DateTime.now(),
      );

      expect(goal.isCompleted(60), false);
      expect(goal.isCompleted(120), true);
      expect(goal.isCompleted(150), true);
    });

    test('getRemainingMinutes calculates correctly', () {
      final goal = Goal(
        id: 'goal1',
        title: 'Test',
        type: GoalType.daily,
        targetMinutes: 120,
        createdAt: DateTime.now(),
      );

      expect(goal.getRemainingMinutes(0), 120);
      expect(goal.getRemainingMinutes(60), 60);
      expect(goal.getRemainingMinutes(120), 0);
      expect(goal.getRemainingMinutes(150), 0); // Clamped at 0
    });

    test('All goal types work correctly', () {
      for (var type in GoalType.values) {
        final goal = Goal(
          id: 'test',
          title: 'Test',
          type: type,
          targetMinutes: 120,
          createdAt: DateTime.now(),
        );

        final json = goal.toJson();
        final restored = Goal.fromJson(json);

        expect(restored.type, type);
      }
    });

    test('GoalType extension displayName returns Vietnamese', () {
      expect(GoalType.daily.displayName, 'Hàng ngày');
      expect(GoalType.weekly.displayName, 'Hàng tuần');
      expect(GoalType.monthly.displayName, 'Hàng tháng');
      expect(GoalType.custom.displayName, 'Tùy chỉnh');
    });

    test('GoalType extension icon returns correct emoji', () {
      expect(GoalType.daily.icon, '📅');
      expect(GoalType.weekly.icon, '📆');
      expect(GoalType.monthly.icon, '🗓️');
      expect(GoalType.custom.icon, '🎯');
    });

    test('fromJson handles missing targetMinutes gracefully', () {
      final json = {
        'id': 'goal1',
        'title': 'Test',
        'type': GoalType.daily.toString(),
        'createdAt': DateTime(2025, 1, 1).toIso8601String(),
        'isActive': true,
      };

      final goal = Goal.fromJson(json);
      expect(goal.targetMinutes, 120); // Default value
    });

    test('Goal with zero target returns zero progress', () {
      final goal = Goal(
        id: 'goal1',
        title: 'Test',
        type: GoalType.daily,
        targetMinutes: 0,
        createdAt: DateTime.now(),
      );

      expect(goal.getProgress(100), 0.0);
    });
  });
}
