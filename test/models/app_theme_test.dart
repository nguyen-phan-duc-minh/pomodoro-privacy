import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/models/app_theme.dart';

void main() {
  group('AppTheme Model Tests', () {
    test('Create app theme with required fields', () {
      final theme = AppTheme(
        id: 'theme1',
        name: 'Test Theme',
        primaryColor: Colors.blue,
        secondaryColor: Colors.green,
        backgroundColor: Colors.white,
        surfaceColor: Colors.grey[100]!,
        textColor: Colors.black,
      );

      expect(theme.id, 'theme1');
      expect(theme.name, 'Test Theme');
      expect(theme.primaryColor, Colors.blue);
      expect(theme.secondaryColor, Colors.green);
      expect(theme.backgroundColor, Colors.white);
      expect(theme.textColor, Colors.black);
      expect(theme.isDefault, false);
    });

    test('toJson and fromJson work correctly', () {
      final theme = AppTheme(
        id: 'theme1',
        name: 'Test Theme',
        primaryColor: const Color(0xFF2196F3),
        secondaryColor: const Color(0xFF4CAF50),
        backgroundColor: const Color(0xFFFFFFFF),
        surfaceColor: const Color(0xFFF5F5F5),
        textColor: const Color(0xFF000000),
        isDefault: true,
      );

      final json = theme.toJson();
      expect(json['id'], 'theme1');
      expect(json['name'], 'Test Theme');
      expect(json['isDefault'], true);

      final restored = AppTheme.fromJson(json);
      expect(restored.id, theme.id);
      expect(restored.name, theme.name);
      expect(restored.primaryColor.value, theme.primaryColor.value);
      expect(restored.secondaryColor.value, theme.secondaryColor.value);
      expect(restored.backgroundColor.value, theme.backgroundColor.value);
      expect(restored.surfaceColor.value, theme.surfaceColor.value);
      expect(restored.textColor.value, theme.textColor.value);
      expect(restored.isDefault, theme.isDefault);
    });

    test('toThemeData creates valid ThemeData', () {
      final appTheme = AppTheme(
        id: 'theme1',
        name: 'Test',
        primaryColor: Colors.blue,
        secondaryColor: Colors.green,
        backgroundColor: Colors.white,
        surfaceColor: Colors.grey[100]!,
        textColor: Colors.black,
      );

      final themeData = appTheme.toThemeData();

      expect(themeData, isA<ThemeData>());
      expect(themeData.useMaterial3, true);
      expect(themeData.scaffoldBackgroundColor, appTheme.backgroundColor);
      expect(themeData.colorScheme.primary, appTheme.primaryColor);
      expect(themeData.colorScheme.secondary, appTheme.secondaryColor);
      expect(themeData.colorScheme.surface, appTheme.surfaceColor);
      expect(themeData.colorScheme.onSurface, appTheme.textColor);
    });

    test('Default themes are available', () {
      expect(AppTheme.lightPastel.id, 'light_pastel');
      expect(AppTheme.darkNeon.id, 'dark_neon');
      expect(AppTheme.galaxy.id, 'galaxy');
      expect(AppTheme.campus.id, 'campus');

      expect(AppTheme.defaultThemes.length, 4);
      expect(AppTheme.defaultThemes[0].isDefault, true);
    });

    test('Light Pastel theme has correct colors', () {
      final theme = AppTheme.lightPastel;

      expect(theme.name, 'Light Pastel');
      expect(theme.primaryColor, const Color(0xFFFFB6D9));
      expect(theme.isDefault, true);
    });

    test('Dark Neon theme has correct colors', () {
      final theme = AppTheme.darkNeon;

      expect(theme.name, 'Dark Neon');
      expect(theme.primaryColor, const Color(0xFFFF006E));
      expect(theme.backgroundColor, const Color(0xFF1A1A2E));
      expect(theme.isDefault, true);
    });

    test('Galaxy theme has correct colors', () {
      final theme = AppTheme.galaxy;

      expect(theme.name, 'Galaxy');
      expect(theme.primaryColor, const Color(0xFF8B5CF6));
      expect(theme.secondaryColor, const Color(0xFFEC4899));
      expect(theme.isDefault, true);
    });

    test('Campus theme has correct colors', () {
      final theme = AppTheme.campus;

      expect(theme.name, 'Campus');
      expect(theme.primaryColor, const Color(0xFF059669));
      expect(theme.secondaryColor, const Color(0xFFF59E0B));
      expect(theme.isDefault, true);
    });

    test('Brightness detection for light theme', () {
      final lightTheme = AppTheme(
        id: 'light',
        name: 'Light',
        primaryColor: Colors.blue,
        secondaryColor: Colors.green,
        backgroundColor: Colors.white,
        surfaceColor: Colors.grey[100]!,
        textColor: Colors.black,
      );

      final themeData = lightTheme.toThemeData();
      expect(themeData.colorScheme.brightness, Brightness.light);
    });

    test('Brightness detection for dark theme', () {
      final darkTheme = AppTheme(
        id: 'dark',
        name: 'Dark',
        primaryColor: Colors.blue,
        secondaryColor: Colors.green,
        backgroundColor: Colors.black,
        surfaceColor: Colors.grey[900]!,
        textColor: Colors.white,
      );

      final themeData = darkTheme.toThemeData();
      expect(themeData.colorScheme.brightness, Brightness.dark);
    });

    test('Contrast color is correct for light backgrounds', () {
      final theme = AppTheme(
        id: 'test',
        name: 'Test',
        primaryColor: Colors.white,
        secondaryColor: Colors.grey,
        backgroundColor: Colors.white,
        surfaceColor: Colors.white,
        textColor: Colors.black,
      );

      final themeData = theme.toThemeData();
      // On light primary, text should be dark
      expect(themeData.colorScheme.onPrimary, Colors.black);
    });

    test('Contrast color is correct for dark backgrounds', () {
      final theme = AppTheme(
        id: 'test',
        name: 'Test',
        primaryColor: Colors.black,
        secondaryColor: Colors.grey,
        backgroundColor: Colors.black,
        surfaceColor: Colors.black,
        textColor: Colors.white,
      );

      final themeData = theme.toThemeData();
      // On dark primary, text should be light
      expect(themeData.colorScheme.onPrimary, Colors.white);
    });

    test('All default themes can be serialized', () {
      for (var theme in AppTheme.defaultThemes) {
        final json = theme.toJson();
        final restored = AppTheme.fromJson(json);

        expect(restored.id, theme.id);
        expect(restored.name, theme.name);
        expect(restored.isDefault, theme.isDefault);
      }
    });

    test('fromJson handles missing isDefault gracefully', () {
      final json = {
        'id': 'test',
        'name': 'Test',
        'primaryColor': Colors.blue.toARGB32(),
        'secondaryColor': Colors.green.toARGB32(),
        'backgroundColor': Colors.white.toARGB32(),
        'surfaceColor': Colors.grey.toARGB32(),
        'textColor': Colors.black.toARGB32(),
      };

      final theme = AppTheme.fromJson(json);
      expect(theme.isDefault, false);
    });
  });
}
