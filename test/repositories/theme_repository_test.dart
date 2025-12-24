import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/services/database_service.dart';
import 'package:promodo_study/core/repositories_sqlite.dart';
import 'package:promodo_study/models/study_theme.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@GenerateMocks([DatabaseService])
import 'theme_repository_test.mocks.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('ThemeRepositorySQLite Tests', () {
    late ThemeRepositorySQLite repository;
    late Database testDb;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE custom_themes (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL,
              study_minutes INTEGER NOT NULL,
              break_minutes INTEGER NOT NULL,
              is_default INTEGER NOT NULL DEFAULT 0,
              study_color INTEGER NOT NULL,
              break_color INTEGER NOT NULL,
              background_color INTEGER NOT NULL
            )
          ''');
        },
      );

      final mockDbService = MockDatabaseService();
      when(mockDbService.database).thenAnswer((_) async => testDb);

      repository = ThemeRepositorySQLite(mockDbService);
      await repository.init();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Save and load custom themes correctly', () async {
      final themes = [
        StudyTheme(
          id: 'custom-1',
          name: 'My Custom Theme',
          studyMinutes: 30,
          breakMinutes: 10,
          studyColor: const Color(0xFF6200EE),
          breakColor: const Color(0xFF03DAC6),
          backgroundColor: const Color(0xFFFFFFFF),
        ),
        StudyTheme(
          id: 'custom-2',
          name: 'Another Theme',
          studyMinutes: 45,
          breakMinutes: 15,
          studyColor: const Color(0xFFFF5722),
          breakColor: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFFF5F5F5),
        ),
      ];

      await repository.saveCustomThemes(themes);
      final loaded = await repository.loadCustomThemes();

      expect(loaded.length, 2);
      
      final theme1 = StudyTheme.fromJson(loaded[0] as Map<String, dynamic>);
      expect(theme1.id, 'custom-1');
      expect(theme1.name, 'My Custom Theme');
      expect(theme1.studyMinutes, 30);
      expect(theme1.breakMinutes, 10);
      expect(theme1.studyColor.value, 0xFF6200EE);
      
      final theme2 = StudyTheme.fromJson(loaded[1] as Map<String, dynamic>);
      expect(theme2.id, 'custom-2');
      expect(theme2.studyMinutes, 45);
    });

    test('Load custom themes returns empty list when no themes exist', () async {
      final loaded = await repository.loadCustomThemes();
      expect(loaded, isEmpty);
    });

    test('Save themes replaces existing themes', () async {
      final themes1 = [
        StudyTheme(
          id: '1',
          name: 'Theme 1',
          studyMinutes: 25,
          breakMinutes: 5,
          studyColor: Colors.blue,
          breakColor: Colors.green,
          backgroundColor: Colors.white,
        ),
      ];

      await repository.saveCustomThemes(themes1);
      var loaded = await repository.loadCustomThemes();
      expect(loaded.length, 1);

      final themes2 = [
        StudyTheme(
          id: '2',
          name: 'Theme 2',
          studyMinutes: 50,
          breakMinutes: 10,
          studyColor: Colors.red,
          breakColor: Colors.yellow,
          backgroundColor: Colors.grey,
        ),
      ];

      await repository.saveCustomThemes(themes2);
      loaded = await repository.loadCustomThemes();
      expect(loaded.length, 1);
      
      final theme = StudyTheme.fromJson(loaded[0] as Map<String, dynamic>);
      expect(theme.id, '2');
    });

    test('Theme colors are preserved correctly', () async {
      const studyColor = Color(0xFF123456);
      const breakColor = Color(0xFF654321);
      const bgColor = Color(0xFFABCDEF);

      final themes = [
        StudyTheme(
          id: 'color-test',
          name: 'Color Test',
          studyMinutes: 25,
          breakMinutes: 5,
          studyColor: studyColor,
          breakColor: breakColor,
          backgroundColor: bgColor,
        ),
      ];

      await repository.saveCustomThemes(themes);
      final loaded = await repository.loadCustomThemes();
      
      final theme = StudyTheme.fromJson(loaded[0] as Map<String, dynamic>);
      expect(theme.studyColor.value, studyColor.value);
      expect(theme.breakColor.value, breakColor.value);
      expect(theme.backgroundColor.value, bgColor.value);
    });

    test('Theme durations are preserved correctly', () async {
      final themes = [
        StudyTheme(
          id: 'duration-test',
          name: 'Duration Test',
          studyMinutes: 123,
          breakMinutes: 45,
          studyColor: Colors.blue,
          breakColor: Colors.green,
          backgroundColor: Colors.white,
        ),
      ];

      await repository.saveCustomThemes(themes);
      final loaded = await repository.loadCustomThemes();
      
      final theme = StudyTheme.fromJson(loaded[0] as Map<String, dynamic>);
      expect(theme.studyMinutes, 123);
      expect(theme.breakMinutes, 45);
    });

    test('Multiple themes can be saved and loaded', () async {
      final themes = List.generate(
        5,
        (i) => StudyTheme(
          id: 'theme-$i',
          name: 'Theme $i',
          studyMinutes: 25 + i * 5,
          breakMinutes: 5 + i,
          studyColor: Color(0xFF000000 + i * 0x111111),
          breakColor: Color(0xFFFFFFFF - i * 0x111111),
          backgroundColor: Colors.white,
        ),
      );

      await repository.saveCustomThemes(themes);
      final loaded = await repository.loadCustomThemes();

      expect(loaded.length, 5);
      
      for (var i = 0; i < 5; i++) {
        final theme = StudyTheme.fromJson(loaded[i] as Map<String, dynamic>);
        expect(theme.id, 'theme-$i');
        expect(theme.name, 'Theme $i');
      }
    });
  });
}
