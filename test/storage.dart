import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Storage {
  final Database _db;

  Storage(this._db);

  static Future<Storage> create({required String dbName}) async {
    final db = await openDatabase(
      dbName,
      onCreate: (db, version) async {
        // Create the preferences table
        await db.execute('''CREATE TABLE IF NOT EXISTS preferences (
            name TEXT PRIMARY KEY,
            value TEXT
          )''');

        // Create the activity logs table
        await db.execute('''CREATE TABLE IF NOT EXISTS activity_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            timestamp TEXT
          )''');

        // Create the achievements table
        await db.execute('''CREATE TABLE IF NOT EXISTS achievements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            completion_date TEXT
          )''');
      },
      version: 1,
    );
    return Storage(db);
  }

  // Insert an activity log
  Future<void> insertActivityLog(ActivityName name, DateTime timestamp) async {
    await _db.insert(
      'activity_logs',
      {
        'name': name.toString(),
        'timestamp': timestamp.toIso8601String(),
      },
      conflictAlgorithm:
          ConflictAlgorithm.ignore, // Avoid inserting duplicate logs
    );
  }

  // Retrieve activity logs
  Future<List<Map<String, dynamic>>> getActivityLogs(
      List<ActivityName> names) async {
    return await _db.query(
      'activity_logs',
      where: 'name IN (${names.map((e) => "'${e.toString()}'").join(', ')})',
    );
  }

  // Insert an achievement
  Future<void> insertAchievement(
      Achievement achievement, DateTime completionDate) async {
    await _db.insert(
      'achievements',
      {
        'name': achievement.toString(),
        'completion_date': completionDate.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Retrieve achievements and their completion dates
  Future<Map<Achievement, DateTime>> getAchievementsCompletionDate(
      List<Achievement> achievements) async {
    final result = await _db.query(
      'achievements',
      where:
          'name IN (${achievements.map((e) => "'${e.toString()}'").join(', ')})',
    );

    if (result.isEmpty) {
      return {};
    }

    // Convert result to Map<Achievement, DateTime> with proper casting
    return {
      for (var row in result)
        Achievement.values
                .firstWhere((e) => e.toString() == (row['name'] as String)):
            DateTime.parse(row['completion_date'] as String)
    };
  }

  // Close the database
  Future<void> close() async {
    await _db.close();
  }
}

// Enum for ActivityName
enum ActivityName {
  breathe,
  meditate,
  all,
}

// Enum for Achievements
enum Achievement {
  breathingExercise,
  meditationStreak,
  all, // Include other achievements as necessary
}
