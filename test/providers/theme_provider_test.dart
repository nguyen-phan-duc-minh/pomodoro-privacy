import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/providers/theme_provider.dart';
import 'package:promodo_study/models/study_theme.dart';
import 'package:promodo_study/core/interfaces.dart';

@GenerateMocks([IThemeRepository])
import 'theme_provider_test.mocks.dart';

void main() {
  group('ThemeProvider Tests', () {
    late ThemeProvider provider;
    late MockIThemeRepository mockRepository;

    setUp(() {
      mockRepository = MockIThemeRepository();
      when(mockRepository.init()).thenAnswer((_) async {});
      when(mockRepository.loadCustomThemes()).thenAnswer((_) async => []);
      when(mockRepository.saveCustomThemes(any)).thenAnswer((_) async {});
      
      provider = ThemeProvider(mockRepository);
    });

    test('Initialize loads custom themes from repository', () async {
      final customThemesData = [
        {
          'id': 'custom-1',
          'name': 'My Custom Theme',
          'studyMinutes': 30,
          'breakMinutes': 10,
          'studyColor': Colors.purple.value,
          'breakColor': Colors.orange.value,
          'backgroundColor': Colors.white.value,
        },
      ];

      when(mockRepository.loadCustomThemes())
          .thenAnswer((_) async => customThemesData);

      await provider.init();

      expect(provider.customThemes.length, 1);
      expect(provider.customThemes.first.name, 'My Custom Theme');
      verify(mockRepository.loadCustomThemes()).called(1);
    });

    test('All themes includes default and custom themes', () async {
      final customThemesData = [
        {
          'id': 'custom-1',
          'name': 'My Custom Theme',
          'studyMinutes': 30,
          'breakMinutes': 10,
          'studyColor': Colors.purple.value,
          'breakColor': Colors.orange.value,
          'backgroundColor': Colors.white.value,
        },
      ];

      when(mockRepository.loadCustomThemes())
          .thenAnswer((_) async => customThemesData);

      await provider.init();

      expect(provider.allThemes.length, greaterThan(1));
      expect(provider.defaultThemes.length, StudyTheme.defaultThemes.length);
      expect(provider.customThemes.length, 1);
    });

    test('Add custom theme', () async {
      await provider.init();

      await provider.addCustomTheme(
        name: 'New Theme',
        studyMinutes: 45,
        breakMinutes: 15,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey.shade100,
      );

      expect(provider.customThemes.length, 1);
      expect(provider.customThemes.first.name, 'New Theme');
      expect(provider.customThemes.first.studyMinutes, 45);
      expect(provider.customThemes.first.breakMinutes, 15);
      verify(mockRepository.saveCustomThemes(any)).called(1);
    });

    test('Update custom theme', () async {
      await provider.init();
      await provider.addCustomTheme(
        name: 'Original Theme',
        studyMinutes: 30,
        breakMinutes: 10,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.white,
      );

      final originalTheme = provider.customThemes.first;
      final updatedTheme = originalTheme.copyWith(
        name: 'Updated Theme',
        studyMinutes: 50,
      );

      await provider.updateCustomTheme(updatedTheme);

      expect(provider.customThemes.first.name, 'Updated Theme');
      expect(provider.customThemes.first.studyMinutes, 50);
      expect(provider.customThemes.first.breakMinutes, 10); // Unchanged
      verify(mockRepository.saveCustomThemes(any)).called(2); // add + update
    });

    test('Delete custom theme', () async {
      await provider.init();
      await provider.addCustomTheme(
        name: 'Theme to Delete',
        studyMinutes: 30,
        breakMinutes: 10,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.white,
      );

      expect(provider.customThemes.length, 1);

      final themeId = provider.customThemes.first.id;
      await provider.deleteCustomTheme(themeId);

      expect(provider.customThemes.length, 0);
      verify(mockRepository.saveCustomThemes(any)).called(2); // add + delete
    });

    test('Get theme by id - default theme', () async {
      await provider.init();

      final defaultThemeId = StudyTheme.defaultThemes.first.id;
      final theme = provider.getThemeById(defaultThemeId);

      expect(theme, isNotNull);
      expect(theme?.id, defaultThemeId);
    });

    test('Get theme by id - custom theme', () async {
      await provider.init();
      await provider.addCustomTheme(
        name: 'Custom Theme',
        studyMinutes: 30,
        breakMinutes: 10,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.white,
      );

      final customThemeId = provider.customThemes.first.id;
      final theme = provider.getThemeById(customThemeId);

      expect(theme, isNotNull);
      expect(theme?.id, customThemeId);
      expect(theme?.name, 'Custom Theme');
    });

    test('Get theme by id - non-existent', () async {
      await provider.init();

      final theme = provider.getThemeById('non-existent-id');

      expect(theme, null);
    });

    test('Update non-existent custom theme does nothing', () async {
      await provider.init();

      final fakeTheme = StudyTheme(
        id: 'fake-id',
        name: 'Fake Theme',
        studyMinutes: 30,
        breakMinutes: 10,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.white,
      );

      await provider.updateCustomTheme(fakeTheme);

      expect(provider.customThemes.length, 0);
      verifyNever(mockRepository.saveCustomThemes(any));
    });

    test('Custom theme persists after reload', () async {
      // First session - add theme
      await provider.init();
      await provider.addCustomTheme(
        name: 'Persistent Theme',
        studyMinutes: 30,
        breakMinutes: 10,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.white,
      );

      // Simulate reload - create new provider with same repository
      final customThemesData = [
        {
          'id': provider.customThemes.first.id,
          'name': 'Persistent Theme',
          'studyMinutes': 30,
          'breakMinutes': 10,
          'studyColor': Colors.blue.value,
          'breakColor': Colors.green.value,
          'backgroundColor': Colors.white.value,
        },
      ];

      when(mockRepository.loadCustomThemes())
          .thenAnswer((_) async => customThemesData);

      final newProvider = ThemeProvider(mockRepository);
      await newProvider.init();

      expect(newProvider.customThemes.length, 1);
      expect(newProvider.customThemes.first.name, 'Persistent Theme');
    });
  });
}
