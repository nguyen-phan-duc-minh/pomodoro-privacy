import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  SharedPreferences? _prefs;
  String? _activeTaskId;
  Function(Task)? onTaskCompleted;

  List<Task> get tasks => _tasks;
  List<Task> get activeTasks => _tasks.where((t) => !t.completed).toList();
  List<Task> get completedTasks => _tasks.where((t) => t.completed).toList();
  Task? get activeTask => _activeTaskId != null 
      ? _tasks.firstWhere((t) => t.id == _activeTaskId, orElse: () => _tasks.first)
      : null;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
  
  // Hoàn thành task và hiển thị popup
  Future<void> completeTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1 && !_tasks[index].completed) {
      _tasks[index] = _tasks[index].copyWith(
        completed: true,
        completedAt: DateTime.now(),
      );
      
      // Gọi callback để hiển thị popup
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
    _prefs?.setString('active_task_id', taskId ?? '');
    notifyListeners();
  }

  Future<void> incrementTaskPomodoro(String taskId, {int studyMinutes = 25}) async {
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
    if (_prefs == null) return;
    
    final tasksJson = _tasks.map((t) => t.toJson()).toList();
    await _prefs!.setString('tasks', jsonEncode(tasksJson));
  }

  Future<void> _loadTasks() async {
    if (_prefs == null) return;
    
    final tasksString = _prefs!.getString('tasks');
    if (tasksString != null) {
      try {
        final List<dynamic> tasksJson = jsonDecode(tasksString);
        _tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
      } catch (e) {
        _tasks = [];
      }
    }

    _activeTaskId = _prefs!.getString('active_task_id');
    notifyListeners();
  }

  Future<void> clearCompletedTasks() async {
    _tasks.removeWhere((t) => t.completed);
    await _saveTasks();
    notifyListeners();
  }
}
