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
  /// Usage:
  /// ```dart
  /// Storage storage = await Storage.create();
  /// ```
  static Future<Storage> create({String dbName = 'storage.db'}) async {
    var db = await openDatabase(join(await getDatabasesPath(), dbName),
        onConfigure: _configureDb, onCreate: _initDb);
    return Storage._create(db);
  }

  /// Closes the database connection. Only use if the `Storage` object won't be used again afterwards (i.e., app close or reset)
  /// Usage:
  /// ```dart
  /// await storage.close();
  /// ```
  void close() async {
    await _db.close();
  }

  /**
   * Achievements functions
   */

  /// Returns true if an achievement has been completed
  ///
  /// Usage:
  /// ```dart
  /// if(await storage.isAchievementCompleted(Achievement.achievement_name)){
  ///   // code to run if true
  /// } else {
  ///   // code to run if false
  /// }
  /// ```
  Future<bool> isAchievementCompleted(Achievement achievement) async{
    return (await getAchievementsCompletionDate([achievement]))[achievement] != null;
  }

  /// Returns the date the achievements were completed
  ///
  /// Usage:
  /// ```dart
  /// var dates = await storage.getAchievementsCompletionDate([Achievement.achievement_1, Achievement.achievement_2]);
  /// print(dates[Achievement.achievement_1]); // outputs 'null' or something like '2024-10-03'
  /// print(dates[Achievement.achievement_2]); // outputs 'null' or something like '2024-10-03'
  /// ```
  Future<Map<Achievement, DateTime?>> getAchievementsCompletionDate(List<Achievement> achievements) async{
    List<Map<String, Object?>> rows = [];
    if(achievements.contains(Achievement.all)){
      rows = (await _db.query(_achievementsTable, columns: ['name', 'completion_date']));
    } else {
      var v = _db.enumListExplode(achievements);
      rows = (await _db.query(_achievementsTable, columns: ['name', 'completion_date'], where: 'name in [${v[0]}]', whereArgs: v[1]));
    }

    Map<Achievement, DateTime?> completionDates = {};
    for (var row in rows) {
      completionDates[Achievement.values.firstWhere((e)=>e.name==row['name'])] = row['completion_date'] != null ? (row['completion_date'] as int).epochDaysToDateTime():null;
    }

    return completionDates;
  }

  /// Marks an achievement as completed using the current date.
  ///
  /// Usage:
  /// ```dart
  /// await storage.setAchievementCompleted(Achievement.achievement_name);
  /// ```
  void setAchievementCompleted(Achievement achievement) async{
    await _db.update(_achievementsTable, {'completion_date': DateTime.now().daysSinceEpoch()}, where: 'name = ?', whereArgs: [achievement.name]);
  }

  /**
   * Activity log functions
   */

  /// Retrieves multiple activity logs
  /// Return result is a `Map', with the key being the activity name and the value being a list of entries for that activity
  /// If no activity logs exist, the list should(?) be empty
  /// Example:
  /// ```flutter
  /// var results = await storage.getActivityLogs([ActivityName.breathe, ActivityName.test]);
  /// print(results[ActivityName.breathe][0]['name']); // outputs 'breathe'
  /// print(results[ActivityName.breathe][0]['completion_date]); // outputs something like '200002' (this is the number of days since the Unix epoch)
  /// ```
  Future<Map<ActivityName, List<Map<String, Object?>>>> getActivityLogs(
      // todo: change return to give DateTime? instead of Object?
      List<ActivityName> activities) async {
    Map<ActivityName, List<Map<String, Object?>>> logs = {};
    for (var activity in activities) {
      logs[activity] = await _db.rawQuery('SELECT '
            'name, '
            'completion_date, '
            'info'
            'FROM'
            '?'
            'INNER JOIN'
            '?'
            'ON'
            'activities.id = activity_id'
            'WHERE'
            'name = ?', [_activityTable,_activityLogTable,activity.name]);
    }

    return logs;
  }

  /// Adds a log to the activity logs
  ///
  /// `name` - the name of the activity
  ///
  /// `info` - info associated with the activity
  ///
  /// *Note: `completion_date` is automatically set to the days since Unix epoch*
  ///
  /// Usage:
  ///
  /// ```dart
  /// await storage.addActivityLog(ActivityName.breathe);
  /// ```
  void addActivityLog(ActivityName name, String? info) async{
    int activityId = (await _db.query(_activityTable, columns: ['id'], where:'name = ?', whereArgs: [name.name]))[0]['id'] as int;
    await _db.insert(_activityLogTable,{'activity_id':activityId,'completion_date':DateTime.now().daysSinceEpoch(),'info':info});
  }

  /**
   * Preferences functions
   */

  /// Retrieves multiple preferences from the database. To retrieve all preferences, pass `PreferenceName.all` in `preferences`
  ///
  /// Usage:
  ///
  /// ```dart
  /// var preferences = await storage.getPreferences([PreferenceName.all]); // returns all preferences
  /// ```
  Future<List<Map<String, Object?>>?> getPreferences(
      List<PreferenceName> preferences) async {
    //todo: return a Map<PreferenceName, int> instead of a list
    /// Return nothing if no preference requested
    if (preferences.isEmpty) return null;

    /// Return all preferences if 'all' was passed
    if (preferences.contains(PreferenceName.all)) {
      return await _db.query(_preferencesTable, columns: ['name', 'value']);
    }

    /// Retrieves 1+ preferences from the table
    var v = _db.enumListExplode(preferences);
    return await _db.query(_preferencesTable,
        columns: ['name', 'value'],
        where: 'name in (${v[0].join(',')})',
        whereArgs: v[1]);
  }

  /// Updates multiple preferences
  ///
  /// Usage:
  ///
  /// ```dart
  /// // sets master volume to 60 and music volume to 100
  /// await storage.updatePreferences({PreferenceName.master_volume: 60, PreferenceName.music_volume: 100});
  /// ```
  void updatePreferences(Map<PreferenceName, int> toUpdate) async {
    Batch batch = _db.batch();
    toUpdate.forEach((PreferenceName key, int value) {
      batch.update(_preferencesTable, <String, Object>{'value': value},
          where: 'name = ?', whereArgs: [key.name]);
    });
    await batch.commit(noResult: true);
  }

  /**
   * DB setup functions
   */

  /// Initializes the database and tables when first creating the database
  /// This should not be called elsewhere
  static _initDb(Database db, int version) async {
    Batch batch = db.batch();

    /// Create preferences table
    batch.execute('CREATE TABLE'
        '? ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(25) NOT NULL,'
        'value INT NOT NULL'
        ');', [_preferencesTable]);

    /// Create activities table
    batch.execute('CREATE TABLE'
        '? ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(25) NOT NULL;',[_activityTable]);

    /// Create activity log table
    batch.execute('CREATE TABLE'
        '? ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'activity_id INTEGER NOT NULL,'
        'completion_date INT NOT NULL,' // measured in days since Unix epoch
        'info TEXT NULL,'
        'FOREIGN KEY(activity_id)'
        'REFERENCES activities(id)', [_activityLogTable]);

    /// Create achievements table
    batch.execute('CREATE TABLE'
        '? ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(50) NOT NULL,' // name of the achievement
        'completion_date INT NULL' // measured in days since Unix epoch
      , [_achievementsTable]
    );

    /// Insert default preferences into the preferences table
    for (PreferenceName preferenceName in PreferenceName.values) {
      if(preferenceName.value == -1) continue;

      batch.insert(_preferencesTable,
          {'name': preferenceName.name, 'value': preferenceName.defaultValue});
    }

    /// Insert activities into the activities table
    for (ActivityName activityName in ActivityName.values) {
      if(activityName.value == -1) continue;

      batch.insert(_activityTable, {'name': activityName.name});
    }

    /// Insert achievements into the achievements table
    for(Achievement achievement in Achievement.values){
      if(achievement.value == -1) continue;
      batch.insert(_achievementsTable, {'name': achievement.name, 'completion_date': null});
    }

    /// Run all SQL commands
    await batch.commit(noResult: true);
  }

  static _configureDb(Database db) async {
    Batch batch = db.batch();
    batch.execute('PRAGMA foreign_keys = ON;');

    await batch.commit(noResult: true);
  }
}

extension EpochExtensions on DateTime {
  /// Gives the number of full days since Unix epoch
  int daysSinceEpoch() {
    return (millisecondsSinceEpoch / 86400000).floor();
  }
}

extension DateTimeEpochExtensions on int{

  /// Returns a DateTime object representing the days since the Unix epoch, assuming this is days
  DateTime epochDaysToDateTime(){
    return DateTime.utc(1970).add(Duration(days:this));
  }
}

extension ListExplode on Database{
  /// Returns the placeholders (?) and the args for a list of enums as [placeholders, args]
  List<List<String>> enumListExplode(List<Enum> s){
    var placeholders = List.filled(s.length, '?');
    var args = s.map((s) => s.name).toList(growable: false);
    return [placeholders, args];
  }
}

enum PreferenceName {
  all(-1, -1),
  // these are example preferences
  master_volume(0, 100),
  music_volume(1, 100),
  sound_fx_volume(2, 100);

  /// enum value
  final int value;

  /// The default value for the preference
  final int defaultValue;

  const PreferenceName(this.value, this.defaultValue);
}

enum ActivityName {
  all(-1),
  breathe(0);

  final int value;

  const ActivityName(this.value);
}

enum Achievement{
  all(-1);

  final int value;
  const Achievement(this.value);
}