import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/providers/app_theme_provider.dart';
import 'package:promodo_study/models/app_theme.dart';
import 'package:promodo_study/core/interfaces.dart';

@GenerateMocks([IAppThemeRepository])
import 'app_theme_provider_test.mocks.dart';

void main() {
  group('AppThemeProvider Tests', () {
    late AppThemeProvider provider;
    late MockIAppThemeRepository mockRepository;

    setUp(() {
      mockRepository = MockIAppThemeRepository();
      when(mockRepository.init()).thenAnswer((_) async {});
      when(mockRepository.loadSelectedTheme()).thenAnswer((_) async => null);
      when(mockRepository.saveSelectedTheme(any)).thenAnswer((_) async {});
      
      provider = AppThemeProvider(mockRepository);
    });

    test('Initialize with default theme', () async {
      await provider.init();

      expect(provider.currentTheme, AppTheme.campus);
      verify(mockRepository.loadSelectedTheme()).called(1);
    });

    test('Initialize with saved theme', () async {
      when(mockRepository.loadSelectedTheme())
          .thenAnswer((_) async => AppTheme.darkNeon.id);

      await provider.init();

      expect(provider.currentTheme, AppTheme.darkNeon);
    });

    test('Set theme', () async {
      await provider.init();

      expect(provider.currentTheme, AppTheme.campus);

      await provider.setTheme(AppTheme.galaxy);

      expect(provider.currentTheme, AppTheme.galaxy);
      verify(mockRepository.saveSelectedTheme(AppTheme.galaxy.id)).called(1);
    });

    test('All themes includes all default themes', () async {
      await provider.init();

      expect(provider.allThemes.length, AppTheme.defaultThemes.length);
      expect(provider.allThemes, containsAll(AppTheme.defaultThemes));
    });

    test('Add custom theme', () async {
      await provider.init();

      final customTheme = AppTheme(
        id: 'custom-1',
        name: 'Custom Theme',
        primaryColor: const Color(0xFF000000),
        secondaryColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFFF0F0F0),
        surfaceColor: const Color(0xFFFFFFFF),
        textColor: const Color(0xFF000000),
      );

      await provider.addCustomTheme(customTheme);

      expect(provider.customThemes.length, 1);
      expect(provider.customThemes.first, customTheme);
      expect(provider.allThemes, contains(customTheme));
    });

    test('Delete custom theme', () async {
      await provider.init();

      final customTheme = AppTheme(
        id: 'custom-1',
        name: 'Custom Theme',
        primaryColor: const Color(0xFF000000),
        secondaryColor: const Color(0xFFFFFFFF),
        backgroundColor: const Color(0xFFF0F0F0),
        surfaceColor: const Color(0xFFFFFFFF),
        textColor: const Color(0xFF000000),
      );

      await provider.addCustomTheme(customTheme);
      expect(provider.customThemes.length, 1);

      await provider.deleteCustomTheme(customTheme.id);

      expect(provider.customThemes.length, 0);
      expect(provider.allThemes, isNot(contains(customTheme)));
    });

    test('Delete non-existent theme does nothing', () async {
      await provider.init();

      await provider.deleteCustomTheme('non-existent-id');

      expect(provider.customThemes.length, 0);
    });

    test('Theme changes trigger notifications', () async {
      await provider.init();

      var notifyCount = 0;
      provider.addListener(() {
        notifyCount++;
      });

      await provider.setTheme(AppTheme.lightPastel);

      expect(notifyCount, 1);
    });

    test('All default themes are available', () async {
      await provider.init();

      expect(provider.allThemes, contains(AppTheme.campus));
      expect(provider.allThemes, contains(AppTheme.lightPastel));
      expect(provider.allThemes, contains(AppTheme.darkNeon));
      expect(provider.allThemes, contains(AppTheme.galaxy));
    });

    test('Theme persists after reload', () async {
      // First session - set theme
      await provider.init();
      await provider.setTheme(AppTheme.galaxy);

      // Simulate reload - create new provider with same repository
      when(mockRepository.loadSelectedTheme())
          .thenAnswer((_) async => AppTheme.galaxy.id);

      final newProvider = AppThemeProvider(mockRepository);
      await newProvider.init();

      expect(newProvider.currentTheme, AppTheme.galaxy);
    });

    test('Invalid theme id loads default', () async {
      when(mockRepository.loadSelectedTheme())
          .thenAnswer((_) async => 'invalid-theme-id');

      await provider.init();

      expect(provider.currentTheme, AppTheme.campus); // Falls back to default
    });
  });
}
