import 'package:flutter/material.dart';
import '../models/app_theme.dart';
import '../core/interfaces.dart';

class AppThemeProvider with ChangeNotifier {
  final IAppThemeRepository _repository;
  AppTheme _currentTheme = AppTheme.campus;
  List<AppTheme> _customThemes = [];

  AppThemeProvider(this._repository);

  AppTheme get currentTheme => _currentTheme;
  List<AppTheme> get allThemes => [...AppTheme.defaultThemes, ..._customThemes];
  List<AppTheme> get customThemes => _customThemes;

  Future<void> init() async {
    await _loadTheme();
    await _loadCustomThemes();
  }

  Future<void> setTheme(AppTheme theme) async {
    _currentTheme = theme;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> addCustomTheme(AppTheme theme) async {
    _customThemes.add(theme);
    await _saveCustomThemes();
    notifyListeners();
  }

  Future<void> deleteCustomTheme(String id) async {
    _customThemes.removeWhere((theme) => theme.id == id);
    await _saveCustomThemes();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    await _repository.saveSelectedTheme(_currentTheme.id);
  }

  Future<void> _loadTheme() async {
    final themeId = await _repository.loadSelectedTheme();
    if (themeId != null) {
      final theme = AppTheme.defaultThemes
          .where((t) => t.id == themeId)
          .firstOrNull;
      if (theme != null) {
        _currentTheme = theme;
        notifyListeners();
      }
    }
  }

  Future<void> _saveCustomThemes() async {
    // Custom themes are stored in the custom_themes table via ThemeRepository
    // For now, we'll keep this empty as AppTheme doesn't have a custom themes table
  }

  Future<void> _loadCustomThemes() async {
    // Load custom themes - for now empty as we focus on selected theme
    notifyListeners();
  }
}
