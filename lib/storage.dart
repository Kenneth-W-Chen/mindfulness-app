import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class Storage {
  late Database _db;
  static const _activityTable = 'activities';
  static const _activityLogTable = 'activity_logs';
  static const _preferencesTable = 'preferences';

  Storage._create(Database db) {
    _db = db;
  }

  /// Creates a Storage object to interact with the database
  static Future<Storage> create({String dbName = 'storage.db'}) async {
    var db = await openDatabase(join(await getDatabasesPath(), dbName),
        onConfigure: _configureDb, onCreate: _initDb);
    return Storage._create(db);
  }

  /// Closes the database connection. Only use if the `Storage` object won't be used again afterwards (i.e., app close or reset)
  void close() async {
    await _db.close();
  }

  /**
   * Activity log functions
   */

  /// Retrieves multiple activity logs
  /// Return result is a `Map', with the key being the activity name and the value being a list of entries for that activity
  /// If no activity logs exist, the list should(?) be empty
  /// Example:
  /// ```flutter
  /// var results = storage.getActivityLogs([ActivityName.breathe, ActivityName.test]);
  /// print(results[ActivityName.breathe][0]['name']); // outputs 'breathe'
  /// print(results[ActivityName.breathe][0]['completion_date]); // outputs something like '200002' (this is the number of days since the Unix epoch)
  /// ```
  Future<Map<ActivityName, List<Map<String, Object?>>>> getActivityLogs(
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
  /// `name` - the name of the activity
  /// `info` - info associated with the activity
  /// Note: `completion_date` is automatically set to the days since Unix epoch
  void addActivityLog(ActivityName name, String? info) async{
    int activityId = (await _db.query(_activityTable, columns: ['id'], where:'name = ?', whereArgs: [name.name]))[0]['id'] as int;
    await _db.insert(_activityLogTable,{'activity_id':activityId,'completion_date':DateTime.now().daysSinceEpoch(),'info':info});
  }

  /**
   * Preferences functions
   */

  /// Retrieves multiple preferences from the database. To retrieve all preferences, pass `PreferenceName.all` in `preferences`
  Future<List<Map<String, Object?>>?> getPreferences(
      List<PreferenceName> preferences) async {
    /// Return nothing if no preference requested
    if (preferences.isEmpty) return null;

    /// Return all preferences if 'all' was passed
    if (preferences.contains(PreferenceName.all)) {
      return await _db.query(_preferencesTable, columns: ['name', 'value']);
    }

    /// Retrieves 1+ preferences from the table
    var placeholders = List.filled(preferences.length, '?');
    var args = preferences.map((pref) => pref.name).toList(growable: false);
    return await _db.query(_preferencesTable,
        columns: ['name', 'value'],
        where: 'name in (${placeholders.join(',')})',
        whereArgs: args);
  }

  /// Updates multiple preferences
  void updatePreferences({required Map<PreferenceName, int> toUpdate}) async {
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
        'completion_date INT NOT NULL,'
        'info TEXT NULL,'
        'FOREIGN KEY(activity_id)'
        'REFERENCES activities(id)', [_activityLogTable]);

    /// Insert default preferences into the preferences table
    for (PreferenceName preferenceName in PreferenceName.values) {
      batch.insert(_preferencesTable,
          {'name': preferenceName.name, 'value': preferenceName.defaultValue});
    }

    /// Insert activities into the activities table
    for (ActivityName activityName in ActivityName.values) {
      batch.insert(_activityTable, {'name': activityName.name});
    }

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

  // returns a DateTime object representing the days since the Unix epoch, assuming this is days
  DateTime epochDaysToDateTime(){
    return DateTime.utc(1970).add(Duration(days:this));
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
