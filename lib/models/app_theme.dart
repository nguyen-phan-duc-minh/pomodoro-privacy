import 'package:flutter/material.dart';

class AppTheme {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final bool isDefault;

  AppTheme({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    this.isDefault = false,
  });

  ThemeData toThemeData() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: _getBrightness(),
        primary: primaryColor,
        onPrimary: _getContrastColor(primaryColor),
        secondary: secondaryColor,
        onSecondary: _getContrastColor(secondaryColor),
        error: Colors.red,
        onError: Colors.white,
        surface: surfaceColor,
        onSurface: textColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 2,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: _getContrastColor(primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: _getContrastColor(primaryColor),
      ),
    );
  }

  Brightness _getBrightness() {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Brightness.light : Brightness.dark;
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'primaryColor': primaryColor.toARGB32(),
      'secondaryColor': secondaryColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
      'surfaceColor': surfaceColor.toARGB32(),
      'textColor': textColor.toARGB32(),
      'isDefault': isDefault,
    };
  }

  factory AppTheme.fromJson(Map<String, dynamic> json) {
    return AppTheme(
      id: json['id'],
      name: json['name'],
      primaryColor: Color(json['primaryColor']),
      secondaryColor: Color(json['secondaryColor']),
      backgroundColor: Color(json['backgroundColor']),
      surfaceColor: Color(json['surfaceColor']),
      textColor: Color(json['textColor']),
      isDefault: json['isDefault'] ?? false,
    );
  }

  static AppTheme get lightPastel => AppTheme(
        id: 'light_pastel',
        name: 'Light Pastel',
        primaryColor: const Color(0xFFFFB6D9),
        secondaryColor: const Color(0xFFD4A5FF),
        backgroundColor: const Color(0xFFFFF5F8),
        surfaceColor: const Color(0xFFFFFFFF),
        textColor: const Color(0xFF2D2D2D),
        isDefault: true,
      );

  static AppTheme get darkNeon => AppTheme(
        id: 'dark_neon',
        name: 'Dark Neon',
        primaryColor: const Color(0xFFFF006E),
        secondaryColor: const Color(0xFF00F5FF),
        backgroundColor: const Color(0xFF1A1A2E),
        surfaceColor: const Color(0xFF16213E),
        textColor: const Color(0xFFE4E4E4),
        isDefault: true,
      );

  static AppTheme get galaxy => AppTheme(
        id: 'galaxy',
        name: 'Galaxy',
        primaryColor: const Color(0xFF8B5CF6),
        secondaryColor: const Color(0xFFEC4899),
        backgroundColor: const Color(0xFF0F172A),
        surfaceColor: const Color(0xFF1E293B),
        textColor: const Color(0xFFF1F5F9),
        isDefault: true,
      );

  static AppTheme get campus => AppTheme(
        id: 'campus',
        name: 'Campus',
        primaryColor: const Color(0xFF059669),
        secondaryColor: const Color(0xFFF59E0B),
        backgroundColor: const Color(0xFFF0FDF4),
        surfaceColor: const Color(0xFFFFFFFF),
        textColor: const Color(0xFF064E3B),
        isDefault: true,
      );

  static List<AppTheme> get defaultThemes => [
        lightPastel,
        darkNeon,
        galaxy,
        campus,
      ];
}
