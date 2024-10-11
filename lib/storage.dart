import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'notification_service.dart';

class Storage {
  late Database _db;
  static const _activityTable = 'activities';
  static const _activityLogTable = 'activity_logs';
  static const _preferencesTable = 'preferences';
  static const _achievementsTable = 'achievements';

  Storage._create(Database db) {
    _db = db;
  }

  static Future<Storage> create({String dbName = 'storage.db'}) async {
    var db = await openDatabase(join(await getDatabasesPath(), dbName),
        onConfigure: _configureDb, onCreate: _initDb);
    return Storage._create(db);
  }

  void close() async {
    await _db.close();
  }

  Future<bool> isAchievementCompleted(Achievement achievement) async {
    return (await getAchievementsCompletionDate([achievement]))[achievement] != null;
  }

  Future<Map<Achievement, DateTime?>> getAchievementsCompletionDate(
      List<Achievement> achievements) async {
    List<Map<String, Object?>> rows = [];
    if (achievements.contains(Achievement.all)) {
      rows = (await _db.query(_achievementsTable, columns: ['name', 'completion_date']));
    } else {
      var v = _db.enumListExplode(achievements);
      rows = (await _db.query(_achievementsTable,
          columns: ['name', 'completion_date'],
          where: 'name in (${v[0].join(',')})',
          whereArgs: v[1]));
    }

    Map<Achievement, DateTime?> completionDates = {};
    for (var row in rows) {
      completionDates[Achievement.values.firstWhere((e) => e.name == row['name'])] =
          row['completion_date'] != null
              ? (row['completion_date'] as int).epochDaysToDateTime()
              : null;
    }

    return completionDates;
  }

  void setAchievementCompleted(Achievement achievement) async {
    await _db.update(_achievementsTable,
        {'completion_date': DateTime.now().daysSinceEpoch()},
        where: 'name = ?', whereArgs: [achievement.name]);
  }

  Future<Map<ActivityName, Map<String, Object?>>> getActivityLogs(
      List<ActivityName> activities) async {
    Map<ActivityName, Map<String, Object?>> logs = {};
    for (var activity in activities) {
      var row = (await _db.rawQuery(
          'SELECT name, completion_date, info FROM $_activityTable '
          'INNER JOIN $_activityLogTable ON activities.id = activity_id '
          'WHERE name = ?', [activity.name]))[0];
      logs[activity] = {
        'completion_date': (row['completion_date'] as int).epochDaysToDateTime(),
        'info': row['info']
      };
    }

    return logs;
  }

  void addActivityLog(ActivityName name, String? info) async {
    int activityId = (await _db.query(_activityTable,
        columns: ['id'], where: 'name = ?', whereArgs: [name.name]))[0]['id'] as int;
    await _db.insert(_activityLogTable, {
      'activity_id': activityId,
      'completion_date': DateTime.now().daysSinceEpoch(),
      'info': info
    });
  }

  Future<Map<PreferenceName, int>?> getPreferences(
      List<PreferenceName> preferences) async {
    if (preferences.isEmpty) return null;
    List<Map<String, Object?>> rows;

    if (preferences.contains(PreferenceName.all)) {
      rows = await _db.query(_preferencesTable, columns: ['name', 'value']);
    } else {
      var v = _db.enumListExplode(preferences);
      rows = await _db.query(_preferencesTable,
          columns: ['name', 'value'], where: 'name in (${v[0].join(',')})', whereArgs: v[1]);
    }

    Map<PreferenceName, int> v = {};
    for (Map<String, Object?> row in rows) {
      v[PreferenceName.values.firstWhere((e) => e.name == row['name'])] = row['value'] as int;
    }
    return v;
  }

  void updatePreferences(Map<PreferenceName, int> toUpdate) async {
    Batch batch = _db.batch();
    toUpdate.forEach((PreferenceName key, int value) {
      batch.update(_preferencesTable, <String, Object>{'value': value},
          where: 'name = ?', whereArgs: [key.name]);
    });
    await batch.commit(noResult: true);
  }

  static _initDb(Database db, int version) async {
    Batch batch = db.batch();

    batch.execute('CREATE TABLE $_preferencesTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(25) NOT NULL,'
        'value INT NOT NULL'
        ');');

    batch.execute('CREATE TABLE $_activityTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(25) NOT NULL);');

    batch.execute('CREATE TABLE $_activityLogTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'activity_id INTEGER NOT NULL,'
        'completion_date INT NOT NULL,'
        'info TEXT NULL,'
        'FOREIGN KEY(activity_id) REFERENCES activities(id));');

    batch.execute('CREATE TABLE $_achievementsTable ('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'name CHAR(50) NOT NULL,'
        'completion_date INT NULL);');

    for (PreferenceName preferenceName in PreferenceName.values) {
      if (preferenceName.value == -1) continue;
      batch.insert(_preferencesTable,
          {'name': preferenceName.name, 'value': preferenceName.defaultValue});
    }

    for (ActivityName activityName in ActivityName.values) {
      if (activityName.value == -1) continue;
      batch.insert(_activityTable, {'name': activityName.name});
    }

    for (Achievement achievement in Achievement.values) {
      if (achievement.value == -1) continue;
      batch.insert(_achievementsTable, {'name': achievement.name, 'completion_date': null});
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
  breathe(0);

  final int value;

  const ActivityName(this.value);
}

enum Achievement {
  all(-1);

  final int value;
  const Achievement(this.value);
}
