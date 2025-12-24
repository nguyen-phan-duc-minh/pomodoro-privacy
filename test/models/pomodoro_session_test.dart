import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/models/pomodoro_session.dart';

void main() {
  group('PomodoroSession Model Tests', () {
    test('Create session with required fields', () {
      final now = DateTime.now();
      final session = PomodoroSession(
        id: 'session1',
        themeId: 'theme1',
        startTime: now,
        studyDuration: 1500, 
        breakDuration: 300, 
      );

      expect(session.id, 'session1');
      expect(session.themeId, 'theme1');
      expect(session.startTime, now);
      expect(session.studyDuration, 1500);
      expect(session.breakDuration, 300);
      expect(session.status, SessionStatus.idle);
      expect(session.currentType, SessionType.study);
      expect(session.completedCycles, 0);
      expect(session.targetCycles, 1);
    });

    test('Calculate remaining time correctly', () {
      final session = PomodoroSession(
        id: '1',
        themeId: 'theme1',
        startTime: DateTime.now(),
        studyDuration: 1500,
        breakDuration: 300,
        elapsedStudyTime: 500,
        elapsedBreakTime: 100,
      );

      expect(session.remainingStudyTime, 1000);
      expect(session.remainingBreakTime, 200);
    });

    test('Calculate progress correctly', () {
      final session = PomodoroSession(
        id: '1',
        themeId: 'theme1',
        startTime: DateTime.now(),
        studyDuration: 1500,
        breakDuration: 300,
        elapsedStudyTime: 750, 
        elapsedBreakTime: 150, 
      );

      expect(session.studyProgress, closeTo(0.5, 0.01));
      expect(session.breakProgress, closeTo(0.5, 0.01));
    });

    test('Calculate total time correctly', () {
      final session = PomodoroSession(
        id: '1',
        themeId: 'theme1',
        startTime: DateTime.now(),
        studyDuration: 1500,
        breakDuration: 300,
        elapsedStudyTime: 1500,
        elapsedBreakTime: 300,
      );

      expect(session.totalStudyTime, 1500);
      expect(session.totalBreakTime, 300);
    });

    test('copyWith updates fields correctly', () {
      final session = PomodoroSession(
        id: '1',
        themeId: 'theme1',
        startTime: DateTime.now(),
        studyDuration: 1500,
        breakDuration: 300,
      );

      final running = session.copyWith(
        status: SessionStatus.running,
        currentType: SessionType.study,
      );

      expect(running.status, SessionStatus.running);
      expect(running.currentType, SessionType.study);
      expect(running.id, session.id); 
    });

    test('toJson and fromJson work correctly', () {
      final now = DateTime.now();
      final session = PomodoroSession(
        id: 'session123',
        themeId: 'theme456',
        startTime: now,
        endTime: now.add(const Duration(hours: 2)),
        studyDuration: 1500,
        breakDuration: 300,
        elapsedStudyTime: 1500,
        elapsedBreakTime: 300,
        completedCycles: 4,
        targetCycles: 4,
        status: SessionStatus.completed,
        currentType: SessionType.breakTime,
      );

      final json = session.toJson();
      final fromJson = PomodoroSession.fromJson(json);

      expect(fromJson.id, session.id);
      expect(fromJson.themeId, session.themeId);
      expect(fromJson.startTime, session.startTime);
      expect(fromJson.endTime, session.endTime);
      expect(fromJson.studyDuration, session.studyDuration);
      expect(fromJson.breakDuration, session.breakDuration);
      expect(fromJson.elapsedStudyTime, session.elapsedStudyTime);
      expect(fromJson.elapsedBreakTime, session.elapsedBreakTime);
      expect(fromJson.completedCycles, session.completedCycles);
      expect(fromJson.targetCycles, session.targetCycles);
      expect(fromJson.status, session.status);
      expect(fromJson.currentType, session.currentType);
    });

    test('Session status transitions', () {
      final session = PomodoroSession(
        id: '1',
        themeId: 'theme1',
        startTime: DateTime.now(),
        studyDuration: 1500,
        breakDuration: 300,
        status: SessionStatus.idle,
      );

      final running = session.copyWith(status: SessionStatus.running);
      expect(running.status, SessionStatus.running);

      final paused = running.copyWith(status: SessionStatus.paused);
      expect(paused.status, SessionStatus.paused);

      final completed = paused.copyWith(
        status: SessionStatus.completed,
        endTime: DateTime.now(),
      );
      expect(completed.status, SessionStatus.completed);
      expect(completed.endTime, isNotNull);
    });

    test('Multiple cycles session', () {
      final session = PomodoroSession(
        id: '1',
        themeId: 'theme1',
        startTime: DateTime.now(),
        studyDuration: 1500,
        breakDuration: 300,
        targetCycles: 4,
        completedCycles: 2,
      );

      expect(session.targetCycles, 4);
      expect(session.completedCycles, 2);

      final nextCycle = session.copyWith(
        completedCycles: session.completedCycles + 1,
      );
      expect(nextCycle.completedCycles, 3);
    });
  });
}
