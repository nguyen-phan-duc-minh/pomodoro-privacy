import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/database_service.dart';
import '../models/study_statistics.dart';
import '../models/task.dart';
import '../models/pomodoro_session.dart';

class MigrationService {
  final DatabaseService _dbService;

  MigrationService(this._dbService);

  Future<bool> migrateFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final db = await _dbService.database;

      final migrationKey = 'migration_to_sqlite_done';
      if (prefs.getBool(migrationKey) == true) {
        print('Migration already completed');
        return true;
      }

      print('Starting migration from SharedPreferences to SQLite...');

      final statsJson = prefs.getString('statistics');
      if (statsJson != null) {
        try {
          final stats = StudyStatistics.fromJson(jsonDecode(statsJson));

          for (final entry in stats.dailyStats.entries) {
            final date = entry.key;
            final daily = entry.value;

            await db.insert('daily_stats', {
              'date': date,
              'total_study_minutes': daily.totalStudyMinutes,
              'total_break_minutes': daily.totalBreakMinutes,
              'completed_cycles': daily.completedCycles,
              'session_count': daily.sessionIds.length,
            });

            for (final sessionId in daily.sessionIds) {
              await db.insert('daily_stats_sessions', {
                'date': date,
                'session_id': sessionId,
              });
            }
          }

          await db.update('streak_info', {
            'current_streak': stats.currentStreak,
            'longest_streak': stats.longestStreak,
            'last_study_date': stats.lastStudyDate?.toIso8601String(),
          }, where: 'id = 1');

          print('✓ Migrated statistics');
        } catch (e) {
          print('✗ Error migrating statistics: $e');
        }
      }

      final tasksJson = prefs.getString('tasks');
      if (tasksJson != null) {
        try {
          final List<dynamic> tasksList = jsonDecode(tasksJson);
          final tasks = tasksList.map((json) => Task.fromJson(json)).toList();

          for (final task in tasks) {
            await db.insert('tasks', {
              'id': task.id,
              'title': task.title,
              'completed': task.completed ? 1 : 0,
              'pomodoros_completed': task.pomodorosCompleted,
              'study_minutes': task.studyMinutes,
              'created_at': task.createdAt.millisecondsSinceEpoch,
              'completed_at': task.completedAt?.millisecondsSinceEpoch,
            });
          }

          print('✓ Migrated ${tasks.length} tasks');
        } catch (e) {
          print('✗ Error migrating tasks: $e');
        }
      }

      final activeTaskId = prefs.getString('active_task_id');
      if (activeTaskId != null && activeTaskId.isNotEmpty) {
        await db.insert('app_settings', {
          'key': 'active_task_id',
          'value': activeTaskId,
        });
        print('✓ Migrated active task ID');
      }

      final currentSessionJson = prefs.getString('current_session');
      if (currentSessionJson != null) {
        try {
          final session = PomodoroSession.fromJson(
            jsonDecode(currentSessionJson),
          );

          await db.insert('sessions', {
            'id': session.id,
            'theme_id': session.themeId,
            'start_time': session.startTime.millisecondsSinceEpoch,
            'end_time': session.endTime?.millisecondsSinceEpoch,
            'study_duration': session.studyDuration,
            'break_duration': session.breakDuration,
            'total_study_time': session.totalStudyTime,
            'total_break_time': session.totalBreakTime,
            'completed_cycles': session.completedCycles,
            'target_cycles': session.targetCycles,
            'status': session.status.toString().split('.').last,
            'current_type': session.currentType.toString().split('.').last,
          });

          print('✓ Migrated current session');
        } catch (e) {
          print('✗ Error migrating session: $e');
        }
      }

      await prefs.setBool(migrationKey, true);
      print('✓ Migration completed successfully!');

      return true;
    } catch (e) {
      print('✗ Migration failed: $e');
      return false;
    }
  }

  Future<void> clearOldData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('statistics');
    await prefs.remove('tasks');
    await prefs.remove('active_task_id');
    await prefs.remove('current_session');
    print('✓ Cleared old SharedPreferences data');
  }
}
