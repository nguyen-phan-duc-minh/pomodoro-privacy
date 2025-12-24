import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/interfaces.dart';
import '../models/study_statistics.dart';
import '../models/task.dart';
import '../models/pomodoro_session.dart';

class StatisticsRepository implements IStatisticsRepository {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveStatistics(statistics) async {
    if (_prefs == null) return;
    final json = jsonEncode((statistics as StudyStatistics).toJson());
    await _prefs!.setString('statistics', json);
  }

  @override
  Future<StudyStatistics?> loadStatistics() async {
    if (_prefs == null) return null;
    final json = _prefs!.getString('statistics');
    if (json != null) {
      try {
        return StudyStatistics.fromJson(jsonDecode(json));
      } catch (e) {
        await _prefs!.remove('statistics');
        return null;
      }
    }
    return null;
  }
}

class TaskRepository implements ITaskRepository {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveTasks(List tasks) async {
    if (_prefs == null) return;
    final tasksJson = (tasks as List<Task>).map((t) => t.toJson()).toList();
    await _prefs!.setString('tasks', jsonEncode(tasksJson));
  }

  @override
  Future<List<Task>> loadTasks() async {
    if (_prefs == null) return [];
    final tasksString = _prefs!.getString('tasks');
    if (tasksString != null) {
      try {
        final List<dynamic> tasksJson = jsonDecode(tasksString);
        return tasksJson.map((json) => Task.fromJson(json)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> saveActiveTaskId(String? taskId) async {
    if (_prefs == null) return;
    await _prefs!.setString('active_task_id', taskId ?? '');
  }

  @override
  Future<String?> loadActiveTaskId() async {
    if (_prefs == null) return null;
    return _prefs!.getString('active_task_id');
  }
}

class SessionRepository implements ISessionRepository {
  SharedPreferences? _prefs;

  @override
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<void> saveSession(session) async {
    if (_prefs == null || session == null) return;
    final json = jsonEncode((session as PomodoroSession).toJson());
    await _prefs!.setString('current_session', json);
  }

  @override
  Future<PomodoroSession?> loadSession() async {
    if (_prefs == null) return null;
    final json = _prefs!.getString('current_session');
    if (json != null) {
      try {
        return PomodoroSession.fromJson(jsonDecode(json));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearSession() async {
    if (_prefs == null) return;
    await _prefs!.remove('current_session');
  }
}
