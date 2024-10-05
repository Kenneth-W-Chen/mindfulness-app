import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' show join;

class Storage {
  late Database _db;

  Storage._create(Database db) {
    _db = db;
  }

  /// Creates a Storage object to interact with the database
  static Future<Storage> create({String dbName = 'storage.db'}) async {
    var db = await openDatabase(join(await getDatabasesPath(), dbName),
        onCreate: _initDb);
    return Storage._create(db);
  }

  /// Closes the database connection
  void close() async {
    await _db.close();
  }

  updatePreferences({required Map<String, int> preferences}) async {}

  /// Retrieves multiple preferences from the database. To retrieve all preferences, pass `PreferenceName.all` in `preferences`
  Future<List<Map<String, Object?>>?> getPreferences(
      List<PreferenceName> preferences) async {
    /// Return nothing if no preference requested
    if (preferences.isEmpty) return null;

    /// Return all preferences if 'all' was passed
    if (preferences.contains(PreferenceName.all)) {
      return await _db.query('preferences', columns: ['pref_name', 'value']);
    }

    /// Retrieves 1+ preferences from the table
    var placeholders = List.filled(preferences.length, '?');
    var args = preferences.map((pref) => pref.name).toList(growable: false);
    return await _db.query('preferences',
        columns: ['pref_name', 'value'],
        where: 'pref_name in (${placeholders.join(',')})',
        whereArgs: args);
  }

  /// Initializes the database and tables when first creating the database
  /// This should not be called elsewhere
  static _initDb(Database db, int version) async {
    await db.execute('CREATE TABLE'
        'preferences('
        'id INTEGER PRIMARY KEY NOT NULL,'
        'pref_name CHAR(25) NOT NULL,'
        'value INT NOT NULL'
        ');');

    /// Insert default preferences into the preferences table
    Batch batch = db.batch();
    batch.insert('preferences', {'pref_name': 'master_volume', 'value': 100});
    batch.insert('preferences', {'pref_name': 'music_volume', 'value': 100});
    batch.insert('preferences', {'pref_name': 'sound_fx_volume', 'value': 100});
    await batch.commit(noResult: true);
  }
}

enum PreferenceName {
  all(-1),
  // these are example preferences
  master_volume(0),
  music_volume(1),
  sound_fx_volume(2);

  final int value;

  const PreferenceName(this.value);
}
