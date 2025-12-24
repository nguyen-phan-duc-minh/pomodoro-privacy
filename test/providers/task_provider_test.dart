import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:promodo_study/providers/task_provider.dart';
import 'package:promodo_study/models/task.dart';
import 'package:promodo_study/core/interfaces.dart';

@GenerateMocks([ITaskRepository])
import 'task_provider_test.mocks.dart';

void main() {
  group('TaskProvider Tests', () {
    late TaskProvider provider;
    late MockITaskRepository mockRepository;

    setUp(() {
      mockRepository = MockITaskRepository();
      when(mockRepository.init()).thenAnswer((_) async {});
      when(mockRepository.loadTasks()).thenAnswer((_) async => []);
      when(mockRepository.loadActiveTaskId()).thenAnswer((_) async => null);
      when(mockRepository.saveTasks(any)).thenAnswer((_) async {});
      when(mockRepository.saveActiveTaskId(any)).thenAnswer((_) async {});
      
      provider = TaskProvider(mockRepository);
    });

    test('Initialize loads tasks from repository', () async {
      final tasks = [
        Task(id: '1', title: 'Task 1', createdAt: DateTime.now()),
        Task(id: '2', title: 'Task 2', createdAt: DateTime.now()),
      ];

      when(mockRepository.loadTasks()).thenAnswer((_) async => tasks);

      await provider.init();

      expect(provider.tasks.length, 2);
      expect(provider.activeTasks.length, 2);
      verify(mockRepository.loadTasks()).called(1);
    });

    test('Add new task', () async {
      await provider.init();

      await provider.addTask('New Task');

      expect(provider.tasks.length, 1);
      expect(provider.tasks.first.title, 'New Task');
      verify(mockRepository.saveTasks(any)).called(1);
    });

    test('Toggle task completion', () async {
      await provider.init();
      await provider.addTask('Task');
      
      final taskId = provider.tasks.first.id;
      final initialCompleted = provider.tasks.first.completed;

      await provider.toggleTask(taskId);

      expect(provider.tasks.first.completed, !initialCompleted);
      verify(mockRepository.saveTasks(any)).called(2); // 1 for add, 1 for toggle
    });

    test('Delete task', () async {
      await provider.init();
      await provider.addTask('Task to delete');
      
      final taskId = provider.tasks.first.id;

      await provider.deleteTask(taskId);

      expect(provider.tasks, isEmpty);
      verify(mockRepository.saveTasks(any)).called(2); // 1 for add, 1 for delete
    });

    test('Active tasks filter', () async {
      await provider.init();
      await provider.addTask('Active Task');
      await provider.addTask('Completed Task');
      
      final taskToComplete = provider.tasks.last.id;
      await provider.toggleTask(taskToComplete);

      expect(provider.activeTasks.length, 1);
      expect(provider.completedTasks.length, 1);
    });

    test('Set active task', () async {
      await provider.init();
      await provider.addTask('Task 1');
      await provider.addTask('Task 2');
      
      final task2Id = provider.tasks.first.id; // First because inserted at index 0

      provider.setActiveTask(task2Id);

      expect(provider.activeTask?.id, task2Id);
    });
  });
}
