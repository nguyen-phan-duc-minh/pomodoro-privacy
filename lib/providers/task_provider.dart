import 'package:flutter/material.dart';
import '../core/interfaces.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  final ITaskRepository _repository;
  List<Task> _tasks = [];
  String? _activeTaskId;
  Function(Task)? onTaskCompleted;

  TaskProvider(this._repository);

  List<Task> get tasks => _tasks;
  List<Task> get activeTasks => _tasks.where((t) => !t.completed).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.completed).toList();
  Task? get activeTask => _activeTaskId != null
      ? _tasks.firstWhere(
          (t) => t.id == _activeTaskId,
          orElse: () => _tasks.first,
        )
      : null;

  Future<void> init() async {
    await _repository.init();
    await _loadTasks();
  }

  Future<void> addTask(String title) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
    );
    _tasks.insert(0, task);
    await _saveTasks();
    notifyListeners();
  }

  Future<void> toggleTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        completed: !_tasks[index].completed,
        completedAt: !_tasks[index].completed ? DateTime.now() : null,
      );
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> completeTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1 && !_tasks[index].completed) {
      _tasks[index] = _tasks[index].copyWith(
        completed: true,
        completedAt: DateTime.now(),
      );
      if (onTaskCompleted != null) {
        onTaskCompleted!(_tasks[index]);
      }
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    if (_activeTaskId == taskId) {
      _activeTaskId = null;
    }
    await _saveTasks();
    notifyListeners();
  }

  Future<void> updateTask(String taskId, String newTitle) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(title: newTitle);
      await _saveTasks();
      notifyListeners();
    }
  }

  void setActiveTask(String? taskId) {
    _activeTaskId = taskId;
    _repository.saveActiveTaskId(taskId);
    notifyListeners();
  }

  Future<void> incrementTaskPomodoro(
    String taskId, {
    int studyMinutes = 25,
  }) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        pomodorosCompleted: _tasks[index].pomodorosCompleted + 1,
        studyMinutes: _tasks[index].studyMinutes + studyMinutes,
      );
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    await _repository.saveTasks(_tasks);
  }

  Future<void> _loadTasks() async {
    final loaded = await _repository.loadTasks();
    _tasks = List<Task>.from(loaded);
    _activeTaskId = await _repository.loadActiveTaskId();
    notifyListeners();
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((t) => t.completed);
    await _saveTasks();
    notifyListeners();
  }
}
