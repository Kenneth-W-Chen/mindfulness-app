import 'package:flutter/cupertino.dart';
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
  static const _moodJournalsTable = 'mood_journals';

  Storage._create(Database db) {
    _db = db;
  }

  /// Creates a Storage object to interact with the database
  static Future<Storage> create({String dbName = 'storage.db'}) async {
    var db = await openDatabase(
      join(await getDatabasesPath(), dbName),
      version: 2, // Updated version for schema changes
      onConfigure: _configureDb,
      onCreate: _initDb,
    );
    return Storage._create(db);
  }

  Future<void> close() async {
    await _db.close();
  }

  /// Adds a log to the activity logs
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

  /// Inserts a new mood journal entry
  Future<void> insertMoodJournal(
      String date, String mood, int intensity, String note) async {
    await _db.insert(
      _moodJournalsTable,
      {
        'date': date,
        'mood': mood,
        'intensity': intensity,
        'note': note,
      },
    );
  }

  /// Retrieves all mood journal entries from the database
  Future<List<Map<String, dynamic>>> getAllMoodJournalEntries() async {
    return await _db.query(
      _moodJournalsTable,
      orderBy: 'date DESC',
    );
  }

  /// Initializes the database schema
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
        'FOREIGN KEY(activity_id) REFERENCES $_activityTable(id)'
        ');');

    // Create achievements table
    batch.execute('CREATE TABLE $_achievementsTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(50) NOT NULL,'
        'completion_date INT NULL,'
        'UNIQUE(name)'
        ');');

    // Create mood journal table
    batch.execute('CREATE TABLE $_moodJournalsTable ('
        'id INTEGER PRIMARY KEY AUTOINCREMENT,'
        'date TEXT NOT NULL,'
        'mood TEXT NOT NULL,'
        'intensity INTEGER NOT NULL,'
        'note TEXT'
        ');');

    await batch.commit(noResult: true);
  }

  /// Configures the database
  static Future<void> _configureDb(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }
}

// Extensions for date and time conversions
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
  breathe(0),
  meditate(1);

  final int value;

  const ActivityName(this.value);
}

enum Achievement {
  all(-1);

  final int value;

  const Achievement(this.value);
}
