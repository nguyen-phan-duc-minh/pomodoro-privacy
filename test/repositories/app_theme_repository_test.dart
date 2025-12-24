import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/services/database_service.dart';
import 'package:promodo_study/core/repositories_sqlite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

@GenerateMocks([DatabaseService])
import 'app_theme_repository_test.mocks.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('AppThemeRepositorySQLite Tests', () {
    late AppThemeRepositorySQLite repository;
    late Database testDb;

    setUp(() async {
      testDb = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE app_settings (
              key TEXT PRIMARY KEY,
              value TEXT
            )
          ''');
        },
      );

      final mockDbService = MockDatabaseService();
      when(mockDbService.database).thenAnswer((_) async => testDb);

      repository = AppThemeRepositorySQLite(mockDbService);
      await repository.init();
    });

    tearDown(() async {
      await testDb.close();
    });

    test('Save and load selected theme correctly', () async {
      const themeId = 'forest';

      await repository.saveSelectedTheme(themeId);
      final loaded = await repository.loadSelectedTheme();

      expect(loaded, themeId);
    });

    test('Load selected theme returns null when not set', () async {
      final loaded = await repository.loadSelectedTheme();
      expect(loaded, null);
    });

    test('Save theme replaces existing theme', () async {
      await repository.saveSelectedTheme('campus');
      var loaded = await repository.loadSelectedTheme();
      expect(loaded, 'campus');

      await repository.saveSelectedTheme('ocean');
      loaded = await repository.loadSelectedTheme();
      expect(loaded, 'ocean');
    });

    test('Theme ID with special characters', () async {
      const specialId = 'theme_with-special.chars@123';

      await repository.saveSelectedTheme(specialId);
      final loaded = await repository.loadSelectedTheme();

      expect(loaded, specialId);
    });

    test('Empty string theme ID', () async {
      await repository.saveSelectedTheme('');
      final loaded = await repository.loadSelectedTheme();

      expect(loaded, '');
    });

    test('All default theme IDs', () async {
      final themeIds = ['campus', 'forest', 'ocean', 'sunset', 'lavender', 'dark'];

      for (final themeId in themeIds) {
        await repository.saveSelectedTheme(themeId);
        final loaded = await repository.loadSelectedTheme();
        expect(loaded, themeId);
      }
    });

    test('Custom theme ID', () async {
      const customThemeId = 'custom-theme-uuid-12345';

      await repository.saveSelectedTheme(customThemeId);
      final loaded = await repository.loadSelectedTheme();

      expect(loaded, customThemeId);
    });

    test('Multiple save operations preserve last value', () async {
      final themes = ['campus', 'forest', 'ocean', 'sunset', 'lavender'];

      for (final theme in themes) {
        await repository.saveSelectedTheme(theme);
      }

      final loaded = await repository.loadSelectedTheme();
      expect(loaded, themes.last);
    });

    test('Very long theme ID', () async {
      final longId = 'theme-' + ('a' * 1000);

      await repository.saveSelectedTheme(longId);
      final loaded = await repository.loadSelectedTheme();

      expect(loaded, longId);
    });

    test('Theme ID persistence across multiple operations', () async {
      // Save theme
      await repository.saveSelectedTheme('forest');
      expect(await repository.loadSelectedTheme(), 'forest');

      // Change to another theme
      await repository.saveSelectedTheme('ocean');
      expect(await repository.loadSelectedTheme(), 'ocean');

      // Change back to original
      await repository.saveSelectedTheme('forest');
      expect(await repository.loadSelectedTheme(), 'forest');
    });
  });
}
