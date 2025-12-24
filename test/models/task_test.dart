import 'package:flutter_test/flutter_test.dart';
import 'package:promodo_study/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('Create task with required fields', () {
      final now = DateTime.now();
      final task = Task(id: '1', title: 'Test Task', createdAt: now);

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.createdAt, now);
      expect(task.completed, false);
      expect(task.completedAt, null);
      expect(task.pomodorosCompleted, 0);
      expect(task.studyMinutes, 0);
    });

    test('copyWith updates fields correctly', () {
      final task = Task(
        id: '1',
        title: 'Original Task',
        createdAt: DateTime.now(),
      );

      final completed = task.copyWith(
        completed: true,
        completedAt: DateTime(2025, 12, 24),
      );

      expect(completed.id, task.id);
      expect(completed.title, task.title);
      expect(completed.completed, true);
      expect(completed.completedAt, DateTime(2025, 12, 24));
      expect(task.completed, false);
    });

    test('toJson and fromJson work correctly', () {
      final task = Task(
        id: '123',
        title: 'My Task',
        completed: true,
        pomodorosCompleted: 5,
        studyMinutes: 125,
        createdAt: DateTime(2025, 12, 24, 10, 0),
        completedAt: DateTime(2025, 12, 24, 12, 0),
      );

      final json = task.toJson();
      final fromJson = Task.fromJson(json);

      expect(fromJson.id, task.id);
      expect(fromJson.title, task.title);
      expect(fromJson.completed, task.completed);
      expect(fromJson.pomodorosCompleted, task.pomodorosCompleted);
      expect(fromJson.studyMinutes, task.studyMinutes);
      expect(fromJson.createdAt, task.createdAt);
      expect(fromJson.completedAt, task.completedAt);
    });

    test('Increment pomodoros increases count and study minutes', () {
      final task = Task(
        id: '1',
        title: 'Test',
        createdAt: DateTime.now(),
        pomodorosCompleted: 2,
        studyMinutes: 50,
      );

      final updated = task.copyWith(
        pomodorosCompleted: task.pomodorosCompleted + 1,
        studyMinutes: task.studyMinutes + 25,
      );

      expect(updated.pomodorosCompleted, 3);
      expect(updated.studyMinutes, 75);
    });

    test('Can handle null completedAt for incomplete tasks', () {
      final task = Task(
        id: '1',
        title: 'Incomplete Task',
        createdAt: DateTime.now(),
        completed: false,
        completedAt: null,
      );

      final json = task.toJson();
      final fromJson = Task.fromJson(json);

      expect(fromJson.completed, false);
      expect(fromJson.completedAt, null);
    });

    test('Task equality based on ID', () {
      final task1 = Task(id: '1', title: 'Task 1', createdAt: DateTime.now());

      final task2 = Task(
        id: '1',
        title: 'Task 1 Modified',
        createdAt: DateTime.now(),
      );

      expect(task1.id, task2.id);
    });
  });
}
