import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' show join;

class Storage {
  late Database _db;

  @visibleForTesting
  Database get testDb => _db;

  static const _activityTable = 'activities';
  static const _activityLogTable = 'activity_logs';
  static const _preferencesTable = 'preferences';
  static const _achievementsTable = 'achievements';
  static const _dailyResetTable = 'last_daily_reset';

  Storage._create(Database db) {
    _db = db;
  }

  /// Creates a Storage object to interact with the database
  /// Usage:
  /// ```dart
  /// Storage storage = await Storage.create();
  /// ```
  static Future<Storage> create({String dbName = 'storage.db'}) async {
    var db = await openDatabase(
      join(await getDatabasesPath(), dbName),
      version: 2, // Ensure the version is specified
      onConfigure: _configureDb,
      onCreate: _initDb,
    );
    return Storage._create(db);
  }

  /// Closes the database connection. Only use if the `Storage` object won't be used again afterwards (i.e., app close or reset)
  /// Usage:
  /// ```dart
  /// await storage.close();
  /// ```
  Future<void> close() async {
    await _db.close();
  }

  /**
   * Achievements functions
   */

  /// Returns true if an achievement has been completed
  /// Usage:
  /// ```dart
  /// if(await storage.isAchievementCompleted(Achievement.achievement_name)){
  ///   // code to run if true
  /// } else {
  ///   // code to run if false
  /// }
  /// ```
  Future<bool> isAchievementCompleted(Achievement achievement) async {
    return (await getAchievementsCompletionDate([achievement]))[achievement] != null;
  }

  /// Returns the date the achievements were completed
  /// Usage:
  /// ```dart
  /// var dates = await storage.getAchievementsCompletionDate([Achievement.achievement_1, Achievement.achievement_2]);
  /// print(dates[Achievement.achievement_1]); // outputs 'null' or something like '2024-10-03'
  /// print(dates[Achievement.achievement_2]); // outputs 'null' or something like '2024-10-03'
  /// ```
  Future<Map<Achievement, DateTime?>> getAchievementsCompletionDate(List<Achievement> achievements) async {
    List<Map<String, Object?>> rows = [];
    if (achievements.contains(Achievement.all)) {
      rows = await _db.query(_achievementsTable, columns: ['name', 'completion_date']);
    } else {
      var v = _db.enumListExplode(achievements);
      rows = await _db.query(
        _achievementsTable,
        columns: ['name', 'completion_date'],
        where: 'name IN (${v[0].join(',')})',
        whereArgs: v[1],
      );
    }

    Map<Achievement, DateTime?> completionDates = {};
    for (var row in rows) {
      completionDates[Achievement.values.firstWhere((e) => e.name == row['name'])] =
      row['completion_date'] != null ? (row['completion_date'] as int).epochDaysToDateTime() : null;
    }

    return completionDates;
  }

  /// Marks an achievement as completed using the current date.
  /// Usage:
  /// ```dart
  /// await storage.setAchievementCompleted(Achievement.achievement_name);
  /// ```
  Future<void> setAchievementCompleted(Achievement achievement) async {
    await _db.update(
      _achievementsTable,
      {'completion_date': DateTime.now().daysSinceEpoch()},
      where: 'name = ?',
      whereArgs: [achievement.name],
    );
  }

  Future<void> deleteAchievement(Achievement achievement) async {
    await _db.delete(_achievementsTable, where: 'name = ?', whereArgs: [achievement.name]);
  }

  /** Activity log functions
   *
   **/

  /// Retrieves multiple activity logs
  /// Return result is a `Map', with the key being an `ActivityName` and the value being a list of maps. Each map has a key of the field name (i.e., 'completion_date' and 'info') and the corresponding value.
  ///
  /// If no activity logs exist, the list should(?) be empty
  ///
  /// Example:
  /// ```flutter
  /// var results = await storage.getActivityLogs([ActivityName.breathe, ActivityName.test]);
  /// print(results[ActivityName.breathe]['completion_date]); // outputs something like '2024-10-08'
  /// ```
  Future<Map<ActivityName, List<Map<String, Object?>>>> getActivityLogs(List<ActivityName> activities) async {
    Map<ActivityName, List<Map<String, Object?>>> logs = {};

    for (var activity in activities) {
      var rows = await _db.rawQuery(
        'SELECT name, completion_date, info FROM $_activityLogTable '
            'INNER JOIN $_activityTable ON $_activityTable.id = $_activityLogTable.activity_id '
            'WHERE $_activityTable.name = ? ORDER BY completion_date DESC',
        [activity.name],
      );

      logs[activity] = [];

      // Only process if rows are found
      if (rows.isNotEmpty) {
        rows.forEach((row){
          logs[activity]!.add({
            'completion_date':
            (row['completion_date'] as int?)?.epochDaysToDateTime(),
            'info': row['info']
          });
        });

      } else {
        // Add an empty log entry if no result is found
        logs[activity]!.add({'completion_date': null, 'info': null});
      }
    }

    return logs;
  }

  /// Adds a log to the activity logs
  /// `name` - the name of the activity
  /// `info` - info associated with the activity
  ///
  /// *Note: `completion_date` is automatically set to the days since Unix epoch*
  ///
  /// Usage:
  ///
  /// ```dart
  ///  await storage.addActivityLog(ActivityName.breathe);
  /// ```
  Future<void> addActivityLog(ActivityName name, String? info) async {
    int activityId = await getActivityId(name);

    await _db.insert(
      _activityLogTable,
      {
        'activity_id': activityId,
        'completion_date': DateTime.now().daysSinceEpoch(),
        'info': info,
      },
    );
  }

  Future<int> getActivityId(ActivityName name) async {
    int activityId = (await _db.query(
      _activityTable,
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [name.name],
    ))[0]['id'] as int;
    return activityId;
  }

  /// Delete an activity log entry
  Future<void> deleteActivityLog(ActivityName activityName) async {
    int activityId = await getActivityId(activityName);
    await _db.delete(_activityLogTable, where: 'activity_id = ?', whereArgs: [activityId]);
  }

  /**
   *  Preferences functions
   */

  /// Retrieves multiple preferences from the database. To retrieve all preferences, pass `PreferenceName.all` in `preferences`
  Future<Map<PreferenceName, int>?> getPreferences(List<PreferenceName> preferences) async {
    if (preferences.isEmpty) return null;
    List<Map<String, Object?>> rows;

    if (preferences.contains(PreferenceName.all)) {
      rows = await _db.query(_preferencesTable, columns: ['name', 'value']);
    } else {
      var v = _db.enumListExplode(preferences);
      rows = await _db.query(
        _preferencesTable,
        columns: ['name', 'value'],
        where: 'name IN (${v[0].join(',')})',
        whereArgs: v[1],
      );
    }

    Map<PreferenceName, int> v = {};
    for (Map<String, Object?> row in rows) {
      v[PreferenceName.values.firstWhere((e) => e.name == row['name'])] = row['value'] as int;
    }
    return v;
  }

  /// Updates multiple preferences
  Future<void> updatePreferences(Map<PreferenceName, int> toUpdate) async {
    Batch batch = _db.batch();
    toUpdate.forEach((PreferenceName key, int value) {
      batch.update(
        _preferencesTable,
        <String, Object>{'value': value},
        where: 'name = ?',
        whereArgs: [key.name],
      );
    });
    await batch.commit(noResult: true);
  }

  /**
   * Treeset functions
   */

  /// Retrieves multiple daily reset info from the database. Specify the date range by setting `startDate` and `endDate`.
  /// Dates will be sorted from newest to oldest (e.g., today's reset info will appear before yesterday's)
  /// If `startDate`/`endDate` is not specified, the current date will be used for the respective parameter.
  Future<List<Map<String,Object>?>> getDailyResetInfo({DateTime? startDate, DateTime? endDate}) async{
    int startSinceEpoch = startDate != null ? startDate.daysSinceEpoch():DateTime.now().daysSinceEpoch();
    int endSinceEpoch = endDate != null ? endDate.daysSinceEpoch():DateTime.now().daysSinceEpoch();

    // throw error if start date is after end date
    if(startSinceEpoch > endSinceEpoch){
      throw ArgumentError('startDate {$startDate} set after endDate {$endDate}');
    }

    // Sets the query args based on startDate and endDate being the same
    String where;
    List<Object> whereArgs;
    if(startSinceEpoch == endSinceEpoch){
      where = 'date == ?';
      whereArgs = [startSinceEpoch];
    } else {
      where = 'date BETWEEN ? AND ?';
      whereArgs = [startSinceEpoch, endSinceEpoch];
    }

    // convert the activity IDs to ActivityNames
    List<Map<String,Object?>> rows = await _db.query(_dailyResetTable, columns: ['date', 'activity_1_id', 'activity_2_id', 'activity_3_id', 'activity_completed'], where: where, whereArgs: whereArgs, orderBy: 'date DESC',);
    List<Map<String,Object>?> parsedRows = [];
    for(int i = 0; i < rows.length; i++){
      parsedRows.add(<String,Object>{
        'date': (rows[i]['date'] as int).epochDaysToDateTime(),
        'activity_1':ActivityName.values[rows[i]['activity_1_id'] as int],
        'activity_2':ActivityName.values[rows[i]['activity_2_id'] as int],
        'activity_3':ActivityName.values[rows[i]['activity_3_id'] as int],
        'activity_completed':rows[i]['activity_completed']!
      });
    }

    return parsedRows;
  }

  /// Resets daily data. Returns the list of ActivityNames selected
  Future<List<Map<String, Object>>> dailyReset() async{
    // try to fetch today's daily reset info to ensure it's not already in there
    List<Map<String,Object>?> latestReset = await getDailyResetInfo();
    if(latestReset.isNotEmpty && latestReset[0] != null){
      // return [latestReset[0]!['activity_1'] as ActivityName,latestReset[0]!['activity_2'] as ActivityName,latestReset[0]!['activity_3'] as ActivityName];
      return [{'activity':latestReset[0]!['activity_1'] as ActivityName, 'completed': ((latestReset[0]!['activity_completed'] as int) & 1) ==1},{'activity':latestReset[0]!['activity_2'] as ActivityName, 'completed': ((latestReset[0]!['activity_completed'] as int) & 2) ==2},{'activity':latestReset[0]!['activity_3'] as ActivityName, 'completed': ((latestReset[0]!['activity_completed'] as int) & 4) ==4}];
    }

    //generate list of activities
    List<int> pickRand = List<int>.generate(ActivityName.values.length-1, (i)=>i+1);
    pickRand.shuffle();
    List<ActivityName> activities = List<ActivityName>.generate(3, (int index)=>ActivityName.values[pickRand[index]], growable: false);
    await _db.insert(_dailyResetTable, <String, Object>{
      'date': DateTime.now().daysSinceEpoch(),
      'activity_1_id':await getActivityId(activities[0]),
      'activity_2_id':await getActivityId(activities[1]),
      'activity_3_id':await getActivityId(activities[2])
    });
    return List<Map<String,Object>>.generate(3, (int index)=>{'activity':activities[index],'completed':false});
  }

  Future<void> setDailyCompleted(int activityNumber) async{
    var row = (await _db.query(_dailyResetTable,columns: ['activity_completed','id'], where: 'date == ?', whereArgs: [DateTime.now().daysSinceEpoch()], limit: 1))[0];
    int completionInfo = row['activity_completed'] as int;
    completionInfo |= (1 << (activityNumber-1));
    await _db.update(_dailyResetTable, {'activity_completed': completionInfo}, where: 'id == ?', whereArgs: [row['id']]);
  }

  /// Retrieves all cues for a specific session ID
Future<List<Map<String, dynamic>>> getCuesForSession(int sessionId) async {
  return await _db.query(
    'cues',
    where: 'session_id = ?',
    whereArgs: [sessionId],
  );
}
/// Inserts a new cue for a specific session
Future<void> insertCue(int sessionId, int timeSec, String message) async {
  await _db.insert(
    'cues',
    {
      'session_id': sessionId,
      'time_sec': timeSec,
      'message': message,
    },
  );
}
/// Inserts a new session into the sessions table
Future<void> insertSession(int sessionId, String name) async {
  await _db.insert(
    'sessions',
    {
      'id': sessionId,
      'name': name,
    },
    conflictAlgorithm: ConflictAlgorithm.ignore,  // Ignores if session already exists
  );
}


  /// For testing only
  Future<void> deletePreference(PreferenceName preference) async {
    await _db.delete(_preferencesTable, where: 'name = ?', whereArgs: [preference.name]);
  }

  /**
   * DB setup functions
   */

  /// Initializes the database and tables when first creating the database
  static Future<void> _initDb(Database db, int version) async {
    Batch batch = db.batch();

    // Create preferences table
    batch.execute('CREATE TABLE $_preferencesTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(25) NOT NULL,'
        'value INT NOT NULL,'
        'UNIQUE(name)'
        ');');

    // Create activities table
    batch.execute('CREATE TABLE $_activityTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(25) NOT NULL,'
        'UNIQUE(name)'
        ');');

    // Create activity logs table
    batch.execute('CREATE TABLE $_activityLogTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'activity_id INTEGER NOT NULL,'
        'completion_date INT NOT NULL,'
        'info TEXT NULL,'
        'FOREIGN KEY(activity_id) REFERENCES $_activityTable(id),'
        'CHECK (info != "INVALID_LOG") ON CONFLICT ROLLBACK'
        ');');

    // Create achievements table
    batch.execute('CREATE TABLE $_achievementsTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(50) NOT NULL,'
        'completion_date INT NULL,'
        'UNIQUE(name)'
        ');');

    // Create sessions table
    batch.execute('CREATE TABLE IF NOT EXISTS sessions ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'name TEXT NOT NULL'
      ');');

    // Create cues table
    batch.execute('CREATE TABLE IF NOT EXISTS cues ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'session_id INTEGER NOT NULL,'
      'time_sec INTEGER NOT NULL,'
      'message TEXT NOT NULL,'
      'FOREIGN KEY(session_id) REFERENCES sessions(id) ON DELETE CASCADE'
      ');');

    // Create daily_reset table
    batch.execute('CREATE TABLE IF NOT EXISTS $_dailyResetTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'date INT NOT NULL,'
        'activity_1_id INTEGER NOT NULL,'
        'activity_2_id INTEGER NOT NULL,'
        'activity_3_id INTEGER NOT NULL,'
        'activity_completed INTEGER NOT NULL DEFAULT 0,'
        'FOREIGN KEY(activity_1_id) REFERENCES $_activityTable(id),'
        'FOREIGN KEY(activity_2_id) REFERENCES $_activityTable(id),'
        'FOREIGN KEY(activity_3_id) REFERENCES $_activityTable(id)'
        ');');

    // Insert default preferences into the preferences table
    for (PreferenceName preferenceName in PreferenceName.values) {
      if (preferenceName.value == -1) continue;

      batch.insert(_preferencesTable, {
        'name': preferenceName.name,
        'value': preferenceName.defaultValue,
      },  conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Insert activities into the activities table
    for (ActivityName activityName in ActivityName.values) {
      if (activityName.value == -1) continue;

      batch.insert(_activityTable, {'name': activityName.name},conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Insert achievements into the achievements table
    for (Achievement achievement in Achievement.values) {
      if (achievement.value == -1) continue;
      batch.insert(_achievementsTable, {'name': achievement.name, 'completion_date': null},conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    // Run all SQL commands
    await batch.commit(noResult: true);
  }

  /// Database configuration options.
  static Future<void> _configureDb(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }
}

// Extension methods for date and time conversions
extension EpochExtensions on DateTime {
  int daysSinceEpoch() {
    return (millisecondsSinceEpoch / 86400000).floor();
  }
}
/// Returns a DateTime object representing the days since the Unix epoch, assuming this is days
///
/// Usage:
///
/// ```dart
/// 365.epochDaysToDateTime(); // gives a DateTime object representing January 1, 1971
/// 0.epochDaysToDateTime(); // gives a DateTime object representing January 1, 1970
/// ```
extension DateTimeEpochExtensions on int {
  DateTime epochDaysToDateTime() {
    return DateTime.utc(1970).add(Duration(days: this));
  }
}

/// Returns the placeholders (?) and the args for a list of enums as [placeholders, args]
///
/// Usage:
/// ```dart
/// Database db = await openDatabase();
/// List<PreferenceName> preferences = [master_volume, max_volume, music_volume];
/// var exploded = db.enumListExplode(preferences);
/// db.query('table', where: 'name in ${exploded[0]}', whereArgs: exploded[1]);
/// ```
extension ListExplode on Database {
  List<List<String>> enumListExplode(List<Enum> s) {
    var placeholders = List.filled(s.length, '?');
    var args = s.map((s) => s.name).toList(growable: false);
    return [placeholders, args];
  }
}

// Enum definitions
enum PreferenceName {
  all(-1, -1),
  master_volume(0, 100),
  music_volume(1, 100),
  sound_fx_volume(2, 100);

  final int value;
  final int defaultValue;

  const PreferenceName(this.value, this.defaultValue);
}

enum ActivityName {
  all(-1),
  meditation_station(0),
  twilight_alley(1),
  breathe(2);
  final int value;

  const ActivityName(this.value);
  @override
  String toString(){
    return name.split('_').map((s)=> s = "${s[0].toUpperCase()}${s.substring(1)}").join(' ');
  }
}

enum Achievement {
  all(-1);

  final int value;

  const Achievement(this.value);
}