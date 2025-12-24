import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;
  static const String _databaseName = 'pomodoro_study.db';
  static const int _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        pomodoros_completed INTEGER NOT NULL DEFAULT 0,
        study_minutes INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        completed_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        theme_id TEXT NOT NULL,
        start_time INTEGER NOT NULL,
        end_time INTEGER,
        study_duration INTEGER NOT NULL,
        break_duration INTEGER NOT NULL,
        total_study_time INTEGER NOT NULL DEFAULT 0,
        total_break_time INTEGER NOT NULL DEFAULT 0,
        completed_cycles INTEGER NOT NULL DEFAULT 0,
        target_cycles INTEGER NOT NULL DEFAULT 1,
        status TEXT NOT NULL,
        current_type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_stats (
        date TEXT PRIMARY KEY,
        total_study_minutes INTEGER NOT NULL DEFAULT 0,
        total_break_minutes INTEGER NOT NULL DEFAULT 0,
        completed_cycles INTEGER NOT NULL DEFAULT 0,
        session_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_stats_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        session_id TEXT NOT NULL,
        FOREIGN KEY (date) REFERENCES daily_stats(date),
        FOREIGN KEY (session_id) REFERENCES sessions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE streak_info (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        current_streak INTEGER NOT NULL DEFAULT 0,
        longest_streak INTEGER NOT NULL DEFAULT 0,
        last_study_date TEXT
      )
    ''');

    await db.insert('streak_info', {
      'id': 1,
      'current_streak': 0,
      'longest_streak': 0,
      'last_study_date': null,
    });

    await db.execute('''
      CREATE TABLE app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        target_minutes INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        completed_at INTEGER,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE achievements (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        target_value INTEGER NOT NULL,
        current_value INTEGER NOT NULL DEFAULT 0,
        is_unlocked INTEGER NOT NULL DEFAULT 0,
        unlocked_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE custom_themes (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        study_minutes INTEGER NOT NULL,
        break_minutes INTEGER NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        study_color INTEGER NOT NULL,
        break_color INTEGER NOT NULL,
        background_color INTEGER NOT NULL
      )
    ''');

    await db.execute('CREATE INDEX idx_tasks_completed ON tasks(completed)');
    await db.execute(
      'CREATE INDEX idx_sessions_start_time ON sessions(start_time)',
    );
    await db.execute('CREATE INDEX idx_sessions_status ON sessions(status)');
    await db.execute('CREATE INDEX idx_daily_stats_date ON daily_stats(date)');
    await db.execute('CREATE INDEX idx_goals_is_active ON goals(is_active)');
    await db.execute('CREATE INDEX idx_goals_type ON goals(type)');
    await db.execute('CREATE INDEX idx_achievements_unlocked ON achievements(is_unlocked)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS goals (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          type TEXT NOT NULL,
          target_minutes INTEGER NOT NULL,
          created_at INTEGER NOT NULL,
          completed_at INTEGER,
          is_active INTEGER NOT NULL DEFAULT 1
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS achievements (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          category TEXT NOT NULL,
          target_value INTEGER NOT NULL,
          current_value INTEGER NOT NULL DEFAULT 0,
          is_unlocked INTEGER NOT NULL DEFAULT 0,
          unlocked_at INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS custom_themes (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          study_minutes INTEGER NOT NULL,
          break_minutes INTEGER NOT NULL,
          is_default INTEGER NOT NULL DEFAULT 0,
          study_color INTEGER NOT NULL,
          break_color INTEGER NOT NULL,
          background_color INTEGER NOT NULL
        )
      ''');

      await db.execute('CREATE INDEX IF NOT EXISTS idx_goals_is_active ON goals(is_active)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_goals_type ON goals(type)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_achievements_unlocked ON achievements(is_unlocked)');
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<void> deleteDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
