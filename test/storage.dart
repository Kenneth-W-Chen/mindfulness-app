import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class Storage {
  late Database _db;
  static const _activityTable = 'activities';
  static const _activityLogTable = 'activity_logs';
  static const _preferencesTable = 'preferences';
  static const _achievementsTable = 'achievements';

  Storage._create(Database db) {
    _db = db;
  }

  /// Creates a Storage object to interact with the database
  static Future<Storage> create({String dbName = 'storage.db'}) async {
    var db = await openDatabase(join(await getDatabasesPath(), dbName),
        version: 1, onConfigure: _configureDb, onCreate: _initDb);
    return Storage._create(db);
  }

  /// Closes the database connection
  void close() async {
    await _db.close();
  }

  /**
   * Achievements functions
   */

  /// Returns true if an achievement has been completed
  Future<bool> isAchievementCompleted(Achievement achievement) async {
    return (await getAchievementsCompletionDate([achievement]))[achievement] !=
        null;
  }

  /// Returns the date the achievements were completed
  Future<Map<Achievement, DateTime?>> getAchievementsCompletionDate(
      List<Achievement> achievements) async {
    List<Map<String, Object?>> rows = [];
    if (achievements.contains(Achievement.all)) {
      rows = (await _db
          .query(_achievementsTable, columns: ['name', 'completion_date']));
    } else {
      var v = _db.enumListExplode(achievements);
      rows = (await _db.query(_achievementsTable,
          columns: ['name', 'completion_date'],
          where: 'name in (${v[0].join(',')})',
          whereArgs: v[1]));
    }

    Map<Achievement, DateTime?> completionDates = {};
    for (var row in rows) {
      completionDates[
              Achievement.values.firstWhere((e) => e.name == row['name'])] =
          row['completion_date'] != null
              ? (row['completion_date'] as int).epochDaysToDateTime()
              : null;
    }

    return completionDates;
  }

  /// Marks an achievement as completed using the current date.
  void setAchievementCompleted(Achievement achievement) async {
    await _db.update(_achievementsTable,
        {'completion_date': DateTime.now().daysSinceEpoch()},
        where: 'name = ?', whereArgs: [achievement.name]);
  }

  /**
   * Activity log functions
   */

  /// Retrieves multiple activity logs
  Future<Map<ActivityName, Map<String, Object?>>> getActivityLogs(
      List<ActivityName> activities) async {
    Map<ActivityName, Map<String, Object?>> logs = {};
    for (var activity in activities) {
      var row = (await _db.rawQuery(
          'SELECT name, completion_date, info FROM $_activityTable INNER JOIN $_activityLogTable ON activities.id = activity_id WHERE name = ?',
          [activity.name]))[0];
      logs[activity] = {
        'completion_date':
            (row['completion_date'] as int).epochDaysToDateTime(),
        'info': row['info']
      };
    }
    return logs;
  }

  /// Adds a log to the activity logs
  void addActivityLog(ActivityName name, String? info) async {
    int activityId = (await _db.query(_activityTable,
        columns: ['id'],
        where: 'name = ?',
        whereArgs: [name.name]))[0]['id'] as int;
    await _db.insert(_activityLogTable, {
      'activity_id': activityId,
      'completion_date': DateTime.now().daysSinceEpoch(),
      'info': info
    });
  }

  Future<void> insertActivityLog(ActivityName name, String? info) async {
    // Get the activity ID from the activity table based on the activity name
    final activityIdResult = await _db.query(_activityTable,
        columns: ['id'], where: 'name = ?', whereArgs: [name.name]);

    if (activityIdResult.isNotEmpty) {
      final int activityId = activityIdResult[0]['id'] as int;

      // Insert the activity log into the activity_logs table
      await _db.insert(_activityLogTable, {
        'activity_id': activityId,
        'completion_date': DateTime.now()
            .daysSinceEpoch(), // Stores the current date as days since Unix epoch
        'info': info
      });
    }
  }

  Future<void> setPreference(PreferenceName name, bool value) async {
    await _db.insert(
      _preferencesTable,
      {
        'name': name.name,
        'value': value ? 1 : 0, // Store as integer (1 for true, 0 for false)
      },
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Replace the existing value if it exists
    );
  }
  /**
   * Preferences functions
   */

  /// Retrieves multiple preferences from the database. To retrieve all preferences, pass `PreferenceName.all`
  Future<Map<PreferenceName, int>?> getPreferences(
      List<PreferenceName> preferences) async {
    if (preferences.isEmpty) return null;
    List<Map<String, Object?>> rows;

    if (preferences.contains(PreferenceName.all)) {
      rows = await _db.query(_preferencesTable, columns: ['name', 'value']);
    } else {
      var v = _db.enumListExplode(preferences);
      rows = await _db.query(_preferencesTable,
          columns: ['name', 'value'],
          where: 'name in (${v[0].join(',')})',
          whereArgs: v[1]);
    }

    Map<PreferenceName, int> result = {};
    for (var row in rows) {
      result[PreferenceName.values.firstWhere((e) => e.name == row['name'])] =
          row['value'] as int;
    }
    return result;
  }

  Future<void> insertAchievement(Achievement achievement, DateTime dateTime) async {
    await _db.update(
      _achievementsTable,
      {'completion_date': DateTime.now().daysSinceEpoch()},
      where: 'name = ?',
      whereArgs: [achievement.name],
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Replace if the achievement exists
    );
  }

  /// Updates multiple preferences
  void updatePreferences(Map<PreferenceName, int> toUpdate) async {
    Batch batch = _db.batch();
    toUpdate.forEach((PreferenceName key, int value) {
      batch.update(_preferencesTable, {'value': value},
          where: 'name = ?', whereArgs: [key.name]);
    });
    await batch.commit(noResult: true);
  }

  /**
   * DB setup functions
   */

  static _initDb(Database db, int version) async {
    Batch batch = db.batch();

    batch.execute(
        'CREATE TABLE $_preferencesTable (id INTEGER PRIMARY KEY NOT NULL, name CHAR(25) NOT NULL, value INT NOT NULL);');
    batch.execute(
        'CREATE TABLE $_activityTable (id INTEGER PRIMARY KEY NOT NULL, name CHAR(25) NOT NULL);');
    batch.execute(
        'CREATE TABLE $_activityLogTable (id INTEGER PRIMARY KEY NOT NULL, activity_id INTEGER NOT NULL, completion_date INT NOT NULL, info TEXT NULL, FOREIGN KEY(activity_id) REFERENCES $_activityTable(id));');
    batch.execute(
        'CREATE TABLE $_achievementsTable (id INTEGER PRIMARY KEY NOT NULL, name CHAR(50) NOT NULL, completion_date INT NULL);');

    for (PreferenceName preference in PreferenceName.values) {
      if (preference.value == -1) continue;
      batch.insert(_preferencesTable,
          {'name': preference.name, 'value': preference.defaultValue});
    }

    for (ActivityName activity in ActivityName.values) {
      if (activity.value == -1) continue;
      batch.insert(_activityTable, {'name': activity.name});
    }

    for (Achievement achievement in Achievement.values) {
      if (achievement.value == -1) continue;
      batch.insert(_achievementsTable,
          {'name': achievement.name, 'completion_date': null});
    }

    await batch.commit(noResult: true);
  }

  static _configureDb(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }
}

extension EpochExtensions on DateTime {
  int daysSinceEpoch() {
    return (millisecondsSinceEpoch / 86400000).floor();
  }
}

extension DateTimeEpochExtensions on int {
  DateTime epochDaysToDateTime() {
    return DateTime.utc(1970).add(Duration(days: this));
  }
}

extension ListExplode on Database {
  List<List<String>> enumListExplode(List<Enum> s) {
    var placeholders = List.filled(s.length, '?');
    var args = s.map((s) => s.name).toList(growable: false);
    return [placeholders, args];
  }
}

enum PreferenceName {
  all(-1),
  dailyReminder(0),
  master_volume(1, 100),
  music_volume(2, 100),
  sound_fx_volume(3, 100);

  final int value;
  final int? defaultValue; // Added for preferences with default values

  const PreferenceName(this.value, [this.defaultValue]);
}

enum ActivityName {
  all(-1),
  breathe(0);

  final int value;

  const ActivityName(this.value);
}

enum Achievement {
  all(-1),
  breathingExercise(0),
  meditationStreak(1);

  final int value;

  const Achievement(this.value);
}
