import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/study_theme.dart';

class ThemeProvider with ChangeNotifier {
  List<StudyTheme> _customThemes = [];
  SharedPreferences? _prefs;

  List<StudyTheme> get allThemes => [...StudyTheme.defaultThemes, ..._customThemes];
  List<StudyTheme> get customThemes => _customThemes;
  List<StudyTheme> get defaultThemes => StudyTheme.defaultThemes;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCustomThemes();
  }

  Future<void> addCustomTheme({
    required String name,
    required int studyMinutes,
    required int breakMinutes,
    required Color studyColor,
    required Color breakColor,
    required Color backgroundColor,
  }) async {
    final theme = StudyTheme(
      id: const Uuid().v4(),
      name: name,
      studyMinutes: studyMinutes,
      breakMinutes: breakMinutes,
      studyColor: studyColor,
      breakColor: breakColor,
      backgroundColor: backgroundColor,
    );

    _customThemes.add(theme);
    await _saveCustomThemes();
    notifyListeners();
  }

  Future<void> updateCustomTheme(StudyTheme theme) async {
    final index = _customThemes.indexWhere((t) => t.id == theme.id);
    if (index != -1) {
      _customThemes[index] = theme;
      await _saveCustomThemes();
      notifyListeners();
    }
  }

  Future<void> deleteCustomTheme(String id) async {
    _customThemes.removeWhere((theme) => theme.id == id);
    await _saveCustomThemes();
    notifyListeners();
  }

  StudyTheme? getThemeById(String id) {
    try {
      return allThemes.firstWhere((theme) => theme.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveCustomThemes() async {
    if (_prefs == null) return;
    
    final jsonList = _customThemes.map((theme) => theme.toJson()).toList();
    await _prefs!.setString('custom_themes', jsonEncode(jsonList));
  }

  Future<void> _loadCustomThemes() async {
    if (_prefs == null) return;
    
    final json = _prefs!.getString('custom_themes');
    if (json != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(json);
        _customThemes = jsonList
            .map((item) => StudyTheme.fromJson(item))
            .toList();
        notifyListeners();
      } catch (e) {
        await _prefs!.remove('custom_themes');
      }
    }
  }
}
