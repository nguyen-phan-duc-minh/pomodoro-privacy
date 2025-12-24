import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/models/study_theme.dart';

void main() {
  group('StudyTheme Model Tests', () {
    test('Create study theme with required fields', () {
      final theme = StudyTheme(
        id: 'theme1',
        name: 'Pomodoro Classic',
        studyMinutes: 25,
        breakMinutes: 5,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
      );

      expect(theme.id, 'theme1');
      expect(theme.name, 'Pomodoro Classic');
      expect(theme.studyMinutes, 25);
      expect(theme.breakMinutes, 5);
      expect(theme.isDefault, false);
      expect(theme.studyColor, Colors.blue);
      expect(theme.breakColor, Colors.green);
      expect(theme.backgroundColor, Colors.grey);
    });

    test('Calculate repetitions correctly', () {
      final theme = StudyTheme(
        id: 'theme1',
        name: 'Test Theme',
        studyMinutes: 25,
        breakMinutes: 5,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
      );

      // 25 + 5 = 30 minutes per cycle
      // 120 minutes / 30 = 4 cycles
      expect(theme.getRepetitions(120), 4);
      expect(theme.getRepetitions(90), 3);
      expect(theme.getRepetitions(45), 1);
      expect(theme.getRepetitions(20), 0);
    });

    test('toJson and fromJson work correctly', () {
      final theme = StudyTheme(
        id: 'theme1',
        name: 'Test Theme',
        studyMinutes: 25,
        breakMinutes: 5,
        isDefault: true,
        studyColor: const Color(0xFF2196F3),
        breakColor: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFF9E9E9E),
      );

      final json = theme.toJson();
      expect(json['id'], 'theme1');
      expect(json['name'], 'Test Theme');
      expect(json['studyMinutes'], 25);
      expect(json['breakMinutes'], 5);
      expect(json['isDefault'], true);

      final restored = StudyTheme.fromJson(json);
      expect(restored.id, theme.id);
      expect(restored.name, theme.name);
      expect(restored.studyMinutes, theme.studyMinutes);
      expect(restored.breakMinutes, theme.breakMinutes);
      expect(restored.isDefault, theme.isDefault);
      expect(restored.studyColor.value, theme.studyColor.value);
      expect(restored.breakColor.value, theme.breakColor.value);
      expect(restored.backgroundColor.value, theme.backgroundColor.value);
    });

    test('copyWith creates new instance with updated values', () {
      final theme = StudyTheme(
        id: 'theme1',
        name: 'Original',
        studyMinutes: 25,
        breakMinutes: 5,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
      );

      final updated = theme.copyWith(
        name: 'Updated',
        studyMinutes: 30,
      );

      expect(updated.id, 'theme1');
      expect(updated.name, 'Updated');
      expect(updated.studyMinutes, 30);
      expect(updated.breakMinutes, 5);
    });

    test('isDefault flag works correctly', () {
      final defaultTheme = StudyTheme(
        id: 'default',
        name: 'Default',
        studyMinutes: 25,
        breakMinutes: 5,
        isDefault: true,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
      );

      final customTheme = StudyTheme(
        id: 'custom',
        name: 'Custom',
        studyMinutes: 30,
        breakMinutes: 10,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
      );

      expect(defaultTheme.isDefault, true);
      expect(customTheme.isDefault, false);
    });

    test('Color serialization preserves color values', () {
      final theme = StudyTheme(
        id: 'theme1',
        name: 'Test',
        studyMinutes: 25,
        breakMinutes: 5,
        studyColor: const Color(0xFF2196F3),
        breakColor: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFF9E9E9E),
      );

      final json = theme.toJson();
      final restored = StudyTheme.fromJson(json);

      expect(restored.studyColor.value, theme.studyColor.value);
      expect(restored.breakColor.value, theme.breakColor.value);
      expect(restored.backgroundColor.value, theme.backgroundColor.value);
    });
  });
}
