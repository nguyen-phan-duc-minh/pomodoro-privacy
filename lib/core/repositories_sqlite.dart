import 'package:sqflite/sqflite.dart';
import '../core/interfaces.dart';
import '../services/database_service.dart';
import '../models/study_statistics.dart';
import '../models/task.dart';
import '../models/pomodoro_session.dart';

class StatisticsRepositorySQLite implements IStatisticsRepository {
  final DatabaseService _dbService;
  Database? _db;

  StatisticsRepositorySQLite(this._dbService);

  @override
  Future<void> init() async {
    _db = await _dbService.database;
  }

  @override
  Future<void> saveStatistics(statistics) async {
    if (_db == null) return;
    final stats = statistics as StudyStatistics;

    for (final entry in stats.dailyStats.entries) {
      final date = entry.key;
      final daily = entry.value;

      await _db!.insert('daily_stats', {
        'date': date,
        'total_study_minutes': daily.totalStudyMinutes,
        'total_break_minutes': daily.totalBreakMinutes,
        'completed_cycles': daily.completedCycles,
        'session_count': daily.sessionIds.length,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await _db!.delete(
        'daily_stats_sessions',
        where: 'date = ?',
        whereArgs: [date],
      );

      for (final sessionId in daily.sessionIds) {
        await _db!.insert('daily_stats_sessions', {
          'date': date,
          'session_id': sessionId,
        });
      }
    }

    await _db!.update('streak_info', {
      'current_streak': stats.currentStreak,
      'longest_streak': stats.longestStreak,
      'last_study_date': stats.lastStudyDate?.toIso8601String(),
    }, where: 'id = 1');
  }

  @override
  Future<StudyStatistics?> loadStatistics() async {
    if (_db == null) return null;

    final streakRows = await _db!.query('streak_info', where: 'id = 1');
    if (streakRows.isEmpty) return StudyStatistics();

    final streakInfo = streakRows.first;
    final currentStreak = streakInfo['current_streak'] as int;
    final longestStreak = streakInfo['longest_streak'] as int;
    final lastStudyDateStr = streakInfo['last_study_date'] as String?;
    final lastStudyDate = lastStudyDateStr != null
        ? DateTime.parse(lastStudyDateStr)
        : null;

    final dailyStatsRows = await _db!.query('daily_stats');
    final Map<String, DailyStatistics> dailyStats = {};

    for (final row in dailyStatsRows) {
      final date = row['date'] as String;
      final dateTime = DateTime.parse(date);

      final sessionRows = await _db!.query(
        'daily_stats_sessions',
        where: 'date = ?',
        whereArgs: [date],
      );
      final sessionIds = sessionRows
          .map((r) => r['session_id'] as String)
          .toSet();

      dailyStats[date] = DailyStatistics(
        date: dateTime,
        totalStudyMinutes: row['total_study_minutes'] as int,
        totalBreakMinutes: row['total_break_minutes'] as int,
        completedCycles: row['completed_cycles'] as int,
        sessionIds: sessionIds.toList(),
      );
    }

    return StudyStatistics(
      dailyStats: dailyStats,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastStudyDate: lastStudyDate,
    );
  }
}

class TaskRepositorySQLite implements ITaskRepository {
  final DatabaseService _dbService;
  Database? _db;

  TaskRepositorySQLite(this._dbService);

  @override
  Future<void> init() async {
    _db = await _dbService.database;
  }

  @override
  Future<void> saveTasks(List tasks) async {
    if (_db == null) return;
    final taskList = tasks as List<Task>;

    final batch = _db!.batch();

    batch.delete('tasks');

    for (final task in taskList) {
      batch.insert('tasks', {
        'id': task.id,
        'title': task.title,
        'completed': task.completed ? 1 : 0,
        'pomodoros_completed': task.pomodorosCompleted,
        'study_minutes': task.studyMinutes,
        'created_at': task.createdAt.millisecondsSinceEpoch,
        'completed_at': task.completedAt?.millisecondsSinceEpoch,
      });
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<List<Task>> loadTasks() async {
    if (_db == null) return [];

    final rows = await _db!.query('tasks', orderBy: 'created_at DESC');

    return rows.map((row) {
      return Task(
        id: row['id'] as String,
        title: row['title'] as String,
        completed: (row['completed'] as int) == 1,
        pomodorosCompleted: row['pomodoros_completed'] as int,
        studyMinutes: row['study_minutes'] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row['created_at'] as int,
        ),
        completedAt: row['completed_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['completed_at'] as int)
            : null,
      );
    }).toList();
  }

  @override
  Future<void> saveActiveTaskId(String? taskId) async {
    if (_db == null) return;

    await _db!.insert('app_settings', {
      'key': 'active_task_id',
      'value': taskId ?? '',
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<String?> loadActiveTaskId() async {
    if (_db == null) return null;

    final rows = await _db!.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['active_task_id'],
    );

    if (rows.isEmpty) return null;
    final value = rows.first['value'] as String?;
    return value?.isEmpty == true ? null : value;
  }
}

class SessionRepositorySQLite implements ISessionRepository {
  final DatabaseService _dbService;
  Database? _db;

  SessionRepositorySQLite(this._dbService);

  @override
  Future<void> init() async {
    _db = await _dbService.database;
  }

  @override
  Future<void> saveSession(session) async {
    if (_db == null || session == null) return;
    final pomodoroSession = session as PomodoroSession;

    await _db!.insert('sessions', {
      'id': pomodoroSession.id,
      'theme_id': pomodoroSession.themeId,
      'start_time': pomodoroSession.startTime.millisecondsSinceEpoch,
      'end_time': pomodoroSession.endTime?.millisecondsSinceEpoch,
      'study_duration': pomodoroSession.studyDuration,
      'break_duration': pomodoroSession.breakDuration,
      'total_study_time': pomodoroSession.totalStudyTime,
      'total_break_time': pomodoroSession.totalBreakTime,
      'completed_cycles': pomodoroSession.completedCycles,
      'target_cycles': pomodoroSession.targetCycles,
      'status': pomodoroSession.status.toString().split('.').last,
      'current_type': pomodoroSession.currentType.toString().split('.').last,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<PomodoroSession?> loadSession() async {
    if (_db == null) return null;

    final rows = await _db!.query(
      'sessions',
      where: 'status != ?',
      whereArgs: ['completed'],
      orderBy: 'start_time DESC',
      limit: 1,
    );

    if (rows.isEmpty) return null;

    final row = rows.first;
    return PomodoroSession(
      id: row['id'] as String,
      themeId: row['theme_id'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(row['start_time'] as int),
      endTime: row['end_time'] != null
          ? DateTime.fromMillisecondsSinceEpoch(row['end_time'] as int)
          : null,
      studyDuration: row['study_duration'] as int,
      breakDuration: row['break_duration'] as int,
      elapsedStudyTime: row['total_study_time'] as int,
      elapsedBreakTime: row['total_break_time'] as int,
      completedCycles: row['completed_cycles'] as int,
      targetCycles: row['target_cycles'] as int,
      status: SessionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == row['status'],
      ),
      currentType: SessionType.values.firstWhere(
        (e) => e.toString().split('.').last == row['current_type'],
      ),
    );
  }

  @override
  Future<void> clearSession() async {
    if (_db == null) return;
  }
}

class GoalRepositorySQLite implements IGoalRepository {
  final DatabaseService _dbService;
  Database? _db;

  GoalRepositorySQLite(this._dbService);

  @override
  Future<void> init() async {
    _db = await _dbService.database;
  }

  @override
  Future<void> saveGoals(List goals) async {
    if (_db == null) return;
    
    await _db!.delete('goals');
    
    for (final goal in goals) {
      final g = goal as dynamic;
      await _db!.insert('goals', {
        'id': g.id,
        'title': g.title,
        'type': g.type.toString(),
        'target_minutes': g.targetMinutes,
        'created_at': g.createdAt.millisecondsSinceEpoch,
        'completed_at': g.completedAt?.millisecondsSinceEpoch,
        'is_active': g.isActive ? 1 : 0,
      });
    }
  }

  @override
  Future<List> loadGoals() async {
    if (_db == null) return [];
    
    final results = await _db!.query('goals', orderBy: 'created_at DESC');
    return results.map((row) {
      return {
        'id': row['id'],
        'title': row['title'],
        'type': row['type'],
        'targetMinutes': row['target_minutes'],
        'createdAt': DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int).toIso8601String(),
        'completedAt': row['completed_at'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(row['completed_at'] as int).toIso8601String()
            : null,
        'isActive': row['is_active'] == 1,
      };
    }).toList();
  }
}

class AchievementRepositorySQLite implements IAchievementRepository {
  final DatabaseService _dbService;
  Database? _db;

  AchievementRepositorySQLite(this._dbService);

  @override
  Future<void> init() async {
    _db = await _dbService.database;
  }

  @override
  Future<void> saveAchievements(List achievements) async {
    if (_db == null) return;
    
    await _db!.delete('achievements');
    
    for (final achievement in achievements) {
      final a = achievement as dynamic;
      await _db!.insert('achievements', {
        'id': a.id,
        'title': a.title,
        'description': a.description,
        'category': a.category.toString(),
        'target_value': a.targetValue,
        'current_value': a.currentValue,
        'is_unlocked': a.isUnlocked ? 1 : 0,
        'unlocked_at': a.unlockedAt?.millisecondsSinceEpoch,
      });
    }
  }

  @override
  Future<List> loadAchievements() async {
    if (_db == null) return [];
    
    final results = await _db!.query('achievements');
    return results.map((row) {
      return {
        'id': row['id'],
        'title': row['title'],
        'description': row['description'],
        'category': row['category'],
        'targetValue': row['target_value'],
        'currentValue': row['current_value'],
        'isUnlocked': row['is_unlocked'] == 1,
        'unlockedAt': row['unlocked_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['unlocked_at'] as int).toIso8601String()
            : null,
      };
    }).toList();
  }
}

class ThemeRepositorySQLite implements IThemeRepository {
  final DatabaseService _dbService;
  Database? _db;

  ThemeRepositorySQLite(this._dbService);

  @override
  Future<void> init() async {
    _db = await _dbService.database;
  }

  @override
  Future<void> saveCustomThemes(List themes) async {
    if (_db == null) return;
    
    await _db!.delete('custom_themes');
    
    for (final theme in themes) {
      final t = theme as dynamic;
      await _db!.insert('custom_themes', {
        'id': t.id,
        'name': t.name,
        'study_minutes': t.studyMinutes,
        'break_minutes': t.breakMinutes,
        'is_default': t.isDefault ? 1 : 0,
        'study_color': t.studyColor.value,
        'break_color': t.breakColor.value,
        'background_color': t.backgroundColor.value,
      });
    }
  }

  @override
  Future<List> loadCustomThemes() async {
    if (_db == null) return [];
    
    final results = await _db!.query('custom_themes');
    return results.map((row) {
      return {
        'id': row['id'],
        'name': row['name'],
        'studyMinutes': row['study_minutes'],
        'breakMinutes': row['break_minutes'],
        'isDefault': row['is_default'] == 1,
        'studyColor': row['study_color'],
        'breakColor': row['break_color'],
        'backgroundColor': row['background_color'],
      };
    }).toList();
  }
}

class BreakActivityRepositorySQLite implements IBreakActivityRepository {
  final DatabaseService _dbService;
  Database? _db;

  BreakActivityRepositorySQLite(this._dbService);

  @override
  Future<void> init() async {
    _db = await _dbService.database;
  }

  @override
  Future<void> saveSelectedActivity(String? activityId) async {
    if (_db == null) return;
    
    await _db!.insert('app_settings', {
      'key': 'selected_break_activity',
      'value': activityId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<String?> loadSelectedActivity() async {
    if (_db == null) return null;
    
    final results = await _db!.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['selected_break_activity'],
    );
    
    if (results.isEmpty) return null;
    return results.first['value'] as String?;
  }
}

class AppThemeRepositorySQLite implements IAppThemeRepository {
  final DatabaseService _dbService;
  Database? _db;

  AppThemeRepositorySQLite(this._dbService);

  @override
  Future<void> init() async {
    _db = await _dbService.database;
  }

  @override
  Future<void> saveSelectedTheme(String themeId) async {
    if (_db == null) return;
    
    await _db!.insert('app_settings', {
      'key': 'selected_app_theme',
      'value': themeId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<String?> loadSelectedTheme() async {
    if (_db == null) return null;
    
    final results = await _db!.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['selected_app_theme'],
    );
    
    if (results.isEmpty) return null;
    return results.first['value'] as String?;
  }
}
