import 'package:flutter/material.dart';

class StudyTheme {
  final String id;
  final String name;
  final int studyMinutes;
  final int breakMinutes;
  final bool isDefault;
  final Color studyColor;
  final Color breakColor;
  final Color backgroundColor;

  StudyTheme({
    required this.id,
    required this.name,
    required this.studyMinutes,
    required this.breakMinutes,
    this.isDefault = false,
    required this.studyColor,
    required this.breakColor,
    required this.backgroundColor,
  });

  int getRepetitions(int totalMinutes) {
    final cycleTime = studyMinutes + breakMinutes;
    return (totalMinutes / cycleTime).floor();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'studyMinutes': studyMinutes,
      'breakMinutes': breakMinutes,
      'isDefault': isDefault,
      'studyColor': studyColor.toARGB32(),
      'breakColor': breakColor.toARGB32(),
      'backgroundColor': backgroundColor.toARGB32(),
    };
  }

  factory StudyTheme.fromJson(Map<String, dynamic> json) {
    return StudyTheme(
      id: json['id'],
      name: json['name'],
      studyMinutes: json['studyMinutes'],
      breakMinutes: json['breakMinutes'],
      isDefault: json['isDefault'] ?? false,
      studyColor: Color(json['studyColor']),
      breakColor: Color(json['breakColor']),
      backgroundColor: Color(json['backgroundColor']),
    );
  }

  StudyTheme copyWith({
    String? id,
    String? name,
    int? studyMinutes,
    int? breakMinutes,
    bool? isDefault,
    Color? studyColor,
    Color? breakColor,
    Color? backgroundColor,
  }) {
    return StudyTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      studyMinutes: studyMinutes ?? this.studyMinutes,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      isDefault: isDefault ?? this.isDefault,
      studyColor: studyColor ?? this.studyColor,
      breakColor: breakColor ?? this.breakColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  static StudyTheme get light => StudyTheme(
        id: 'light',
        name: 'Nhẹ',
        studyMinutes: 20,
        breakMinutes: 5,
        isDefault: true,
        studyColor: const Color(0xFFFF6B6B),
        breakColor: const Color(0xFF4ECDC4),
        backgroundColor: const Color(0xFFFFE66D),
      );

  static StudyTheme get medium => StudyTheme(
        id: 'medium',
        name: 'Vừa',
        studyMinutes: 30,
        breakMinutes: 5,
        isDefault: true,
        studyColor: const Color(0xFFFF8C42),
        breakColor: const Color(0xFF95E1D3),
        backgroundColor: const Color(0xFFFEA47F),
      );

  static StudyTheme get average => StudyTheme(
        id: 'average',
        name: 'Trung bình',
        studyMinutes: 45,
        breakMinutes: 10,
        isDefault: true,
        studyColor: const Color(0xFFEE5A6F),
        breakColor: const Color(0xFF92A8D1),
        backgroundColor: const Color(0xFFF7B731),
      );

  static StudyTheme get deep => StudyTheme(
        id: 'deep',
        name: 'Sâu',
        studyMinutes: 60,
        breakMinutes: 15,
        isDefault: true,
        studyColor: const Color(0xFF6C5CE7),
        breakColor: const Color(0xFF00B894),
        backgroundColor: const Color(0xFFFD79A8),
      );

  static List<StudyTheme> get defaultThemes => [
        light,
        medium,
        average,
        deep,
      ];
}
