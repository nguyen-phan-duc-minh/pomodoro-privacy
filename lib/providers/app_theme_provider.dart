import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_theme.dart';

class AppThemeProvider with ChangeNotifier {
  AppTheme _currentTheme = AppTheme.campus;
  List<AppTheme> _customThemes = [];
  SharedPreferences? _prefs;

  AppTheme get currentTheme => _currentTheme;
  List<AppTheme> get allThemes => [...AppTheme.defaultThemes, ..._customThemes];
  List<AppTheme> get customThemes => _customThemes;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
    if (_prefs == null) return;
    await _prefs!.setString('current_theme_id', _currentTheme.id);
  }

  Future<void> _loadTheme() async {
    if (_prefs == null) return;
    
    final themeId = _prefs!.getString('current_theme_id');
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
    if (_prefs == null) return;
    
    final jsonList = _customThemes.map((theme) => theme.toJson()).toList();
    await _prefs!.setString('custom_app_themes', jsonEncode(jsonList));
  }

  Future<void> _loadCustomThemes() async {
    if (_prefs == null) return;
    
    final json = _prefs!.getString('custom_app_themes');
    if (json != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(json);
        _customThemes = jsonList.map((item) => AppTheme.fromJson(item)).toList();
        
        final customTheme = _customThemes
            .where((t) => t.id == _currentTheme.id)
            .firstOrNull;
        if (customTheme != null) {
          _currentTheme = customTheme;
        }
        
        notifyListeners();
      } catch (e) {
        await _prefs!.remove('custom_app_themes');
      }
    }
  }
}
