import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/study_theme.dart';
import '../core/interfaces.dart';

class ThemeProvider with ChangeNotifier {
  final IThemeRepository _repository;
  List<StudyTheme> _customThemes = [];

  ThemeProvider(this._repository);

  List<StudyTheme> get allThemes => [
    ...StudyTheme.defaultThemes,
    ..._customThemes,
  ];
  List<StudyTheme> get customThemes => _customThemes;
  List<StudyTheme> get defaultThemes => StudyTheme.defaultThemes;

  Future<void> init() async {
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
    await _repository.saveCustomThemes(_customThemes);
  }

  Future<void> _loadCustomThemes() async {
    final themesData = await _repository.loadCustomThemes();
    _customThemes = themesData.map((json) => StudyTheme.fromJson(json as Map<String, dynamic>)).toList();
    notifyListeners();
  }
}
