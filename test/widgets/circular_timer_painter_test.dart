import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/widgets/circular_timer_painter.dart';

void main() {
  group('CircularTimerPainter Tests', () {
    test('Creates painter with required properties', () {
      final painter = CircularTimerPainter(
        studyProgress: 0.5,
        breakProgress: 0.3,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
        isStudyPhase: true,
      );

      expect(painter.studyProgress, 0.5);
      expect(painter.breakProgress, 0.3);
      expect(painter.studyColor, Colors.blue);
      expect(painter.breakColor, Colors.green);
      expect(painter.backgroundColor, Colors.grey);
      expect(painter.isStudyPhase, true);
    });

    test('shouldRepaint returns true when progress changes', () {
      final painter1 = CircularTimerPainter(
        studyProgress: 0.5,
        breakProgress: 0.3,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
        isStudyPhase: true,
      );

      final painter2 = CircularTimerPainter(
        studyProgress: 0.6,
        breakProgress: 0.3,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
        isStudyPhase: true,
      );

      expect(painter1.shouldRepaint(painter2), true);
    });

    test('shouldRepaint returns true when phase changes', () {
      final painter1 = CircularTimerPainter(
        studyProgress: 0.5,
        breakProgress: 0.3,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
        isStudyPhase: true,
      );

      final painter2 = CircularTimerPainter(
        studyProgress: 0.5,
        breakProgress: 0.3,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
        isStudyPhase: false,
      );

      expect(painter1.shouldRepaint(painter2), true);
    });

    test('shouldRepaint returns false when nothing changes', () {
      final painter1 = CircularTimerPainter(
        studyProgress: 0.5,
        breakProgress: 0.3,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
        isStudyPhase: true,
      );

      final painter2 = CircularTimerPainter(
        studyProgress: 0.5,
        breakProgress: 0.3,
        studyColor: Colors.blue,
        breakColor: Colors.green,
        backgroundColor: Colors.grey,
        isStudyPhase: true,
      );

      expect(painter1.shouldRepaint(painter2), false);
    });

    testWidgets('Painter renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: CircularTimerPainter(
                studyProgress: 0.75,
                breakProgress: 0.5,
                studyColor: Colors.blue,
                breakColor: Colors.green,
                backgroundColor: Colors.grey,
                isStudyPhase: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Painter handles zero progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: CircularTimerPainter(
                studyProgress: 0.0,
                breakProgress: 0.0,
                studyColor: Colors.blue,
                breakColor: Colors.green,
                backgroundColor: Colors.grey,
                isStudyPhase: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Painter handles full progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: CircularTimerPainter(
                studyProgress: 1.0,
                breakProgress: 1.0,
                studyColor: Colors.blue,
                breakColor: Colors.green,
                backgroundColor: Colors.grey,
                isStudyPhase: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Painter renders in break phase', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomPaint(
              size: const Size(200, 200),
              painter: CircularTimerPainter(
                studyProgress: 1.0,
                breakProgress: 0.5,
                studyColor: Colors.orange,
                breakColor: Colors.lightBlue,
                backgroundColor: Colors.grey,
                isStudyPhase: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
