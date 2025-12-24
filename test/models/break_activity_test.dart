import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/models/break_activity.dart';

void main() {
  group('BreakActivity Model Tests', () {
    test('Create break activity with required fields', () {
      final activity = BreakActivity(
        id: 'act1',
        name: 'Stretch',
        description: 'Do some stretching exercises',
        icon: Icons.directions_walk,
        durationMinutes: 5,
        category: ActivityCategory.physical,
      );

      expect(activity.id, 'act1');
      expect(activity.name, 'Stretch');
      expect(activity.description, 'Do some stretching exercises');
      expect(activity.icon, Icons.directions_walk);
      expect(activity.durationMinutes, 5);
      expect(activity.category, ActivityCategory.physical);
    });

    test('toJson and fromJson work correctly', () {
      final activity = BreakActivity(
        id: 'act1',
        name: 'Meditate',
        description: 'Practice mindfulness',
        icon: Icons.self_improvement,
        durationMinutes: 10,
        category: ActivityCategory.mental,
      );

      final json = activity.toJson();
      expect(json['id'], 'act1');
      expect(json['name'], 'Meditate');
      expect(json['description'], 'Practice mindfulness');
      expect(json['durationMinutes'], 10);
      expect(json['category'], ActivityCategory.mental.index);

      final restored = BreakActivity.fromJson(json);
      expect(restored.id, activity.id);
      expect(restored.name, activity.name);
      expect(restored.description, activity.description);
      expect(restored.durationMinutes, activity.durationMinutes);
      expect(restored.category, activity.category);
      expect(restored.icon.codePoint, activity.icon.codePoint);
    });

    test('getCategoryName returns correct Vietnamese name', () {
      final physical = BreakActivity(
        id: '1',
        name: 'Walk',
        description: 'Take a walk',
        icon: Icons.directions_walk,
        durationMinutes: 5,
        category: ActivityCategory.physical,
      );

      final mental = BreakActivity(
        id: '2',
        name: 'Breathe',
        description: 'Deep breathing',
        icon: Icons.air,
        durationMinutes: 5,
        category: ActivityCategory.mental,
      );

      final social = BreakActivity(
        id: '3',
        name: 'Chat',
        description: 'Talk to someone',
        icon: Icons.chat,
        durationMinutes: 5,
        category: ActivityCategory.social,
      );

      final creative = BreakActivity(
        id: '4',
        name: 'Draw',
        description: 'Sketch something',
        icon: Icons.draw,
        durationMinutes: 5,
        category: ActivityCategory.creative,
      );

      expect(physical.getCategoryName(), 'Vận động');
      expect(mental.getCategoryName(), 'Thư giãn');
      expect(social.getCategoryName(), 'Xã hội');
      expect(creative.getCategoryName(), 'Sáng tạo');
    });

    test('All activity categories can be serialized', () {
      for (var category in ActivityCategory.values) {
        final activity = BreakActivity(
          id: 'test',
          name: 'Test',
          description: 'Test activity',
          icon: Icons.star,
          durationMinutes: 5,
          category: category,
        );

        final json = activity.toJson();
        final restored = BreakActivity.fromJson(json);

        expect(restored.category, category);
      }
    });

    test('Icon serialization preserves icon data', () {
      final icons = [
        Icons.directions_walk,
        Icons.self_improvement,
        Icons.chat,
        Icons.palette,
      ];

      for (var icon in icons) {
        final activity = BreakActivity(
          id: 'test',
          name: 'Test',
          description: 'Test',
          icon: icon,
          durationMinutes: 5,
          category: ActivityCategory.physical,
        );

        final json = activity.toJson();
        final restored = BreakActivity.fromJson(json);

        expect(restored.icon.codePoint, icon.codePoint);
      }
    });

    test('Different duration values are preserved', () {
      final durations = [1, 5, 10, 15, 30];

      for (var duration in durations) {
        final activity = BreakActivity(
          id: 'test',
          name: 'Test',
          description: 'Test',
          icon: Icons.star,
          durationMinutes: duration,
          category: ActivityCategory.physical,
        );

        final json = activity.toJson();
        final restored = BreakActivity.fromJson(json);

        expect(restored.durationMinutes, duration);
      }
    });
  });
}
