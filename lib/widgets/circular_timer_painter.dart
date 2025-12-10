import 'package:flutter/material.dart';
import 'dart:math' as math;

class CircularTimerPainter extends CustomPainter {
  final double studyProgress;
  final double breakProgress;
  final Color studyColor;
  final Color breakColor;
  final Color backgroundColor;
  final bool isStudyPhase;

  CircularTimerPainter({
    required this.studyProgress,
    required this.breakProgress,
    required this.studyColor,
    required this.breakColor,
    required this.backgroundColor,
    required this.isStudyPhase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 20;
    final innerRadius = size.width / 2 - 60;

    final backgroundPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, outerRadius - 15, backgroundPaint);
    canvas.drawCircle(center, innerRadius - 15, backgroundPaint);

    final outerPaint = Paint()
      ..color = studyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    final outerRect = Rect.fromCircle(center: center, radius: outerRadius - 15);
    canvas.drawArc(
      outerRect,
      -math.pi / 2,
      2 * math.pi * studyProgress,
      false,
      outerPaint,
    );

    if (isStudyPhase) {
      final glowPaint = Paint()
        ..color = studyColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 35
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawArc(
        outerRect,
        -math.pi / 2,
        2 * math.pi * studyProgress,
        false,
        glowPaint,
      );
    }

    final innerPaint = Paint()
      ..color = breakColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    final innerRect = Rect.fromCircle(center: center, radius: innerRadius - 15);
    canvas.drawArc(
      innerRect,
      -math.pi / 2,
      2 * math.pi * breakProgress,
      false,
      innerPaint,
    );

    if (!isStudyPhase) {
      final glowPaint = Paint()
        ..color = breakColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 35
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawArc(
        innerRect,
        -math.pi / 2,
        2 * math.pi * breakProgress,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularTimerPainter oldDelegate) {
    return studyProgress != oldDelegate.studyProgress ||
        breakProgress != oldDelegate.breakProgress ||
        isStudyPhase != oldDelegate.isStudyPhase;
  }
}
