import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AudioManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  Database? _database;
  bool isPlaying = false;
  bool loop = false;
  double volume = 1.0;

  Future<void> initializeDatabase() async {
    String path = join(await getDatabasesPath(), 'mindfulness_audio.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        db.execute("CREATE TABLE IF NOT EXISTS sessions (id INTEGER PRIMARY KEY, name TEXT)");
        db.execute("CREATE TABLE IF NOT EXISTS cues (id INTEGER PRIMARY KEY AUTOINCREMENT, session_id INTEGER, time_sec INTEGER, message TEXT, FOREIGN KEY (session_id) REFERENCES sessions (id))");
        db.execute("CREATE TABLE IF NOT EXISTS preferences (id INTEGER PRIMARY KEY, volume REAL)");
      },
    );
    print("Database initialized.");

    // Initialize preferences if not set
    final prefs = await _database?.query('preferences');
    if (prefs == null || prefs.isEmpty) {
      await _database?.insert('preferences', {'volume': 1.0}); // default volume
    } else {
      volume = prefs[0]['volume'] as double;
    }
  }

  Future<void> initializeAudioSession(int sessionId, String name) async {
    await _database?.insert(
      'sessions',
      {'id': sessionId, 'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    print("Session $sessionId initialized with name: $name.");
  }

  Future<void> playAudio(String audioFile, {bool loop = false}) async {
    this.loop = loop;
    isPlaying = true;
    await _audioPlayer.setVolume(volume);
    await _audioPlayer.play(AssetSource(audioFile), isLocal: true);
    _audioPlayer.onPlayerComplete.listen((_) {
      if (loop) {
        playAudio(audioFile, loop: true);
      } else {
        isPlaying = false;
      }
    });
    print("Playing audio: $audioFile");
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    isPlaying = false;
    print("Audio paused.");
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
    isPlaying = true;
    print("Audio resumed.");
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    isPlaying = false;
    print("Audio stopped.");
  }

  Future<void> adjustVolume(double level) async {
    volume = level.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(volume);
    await _database?.update('preferences', {'volume': volume}, where: 'id = ?', whereArgs: [1]);
    print("Volume set to ${(volume * 100).toStringAsFixed(0)}% and saved in preferences.");
  }

  Future<void> addMindfulnessCue(int sessionId, int timeSec, String message) async {
    await _database?.insert(
      'cues',
      {'session_id': sessionId, 'time_sec': timeSec, 'message': message},
    );
    print("Cue added at $timeSec seconds: $message");
  }

  Future<int> fetchAudioDuration(String audioFile) async {
    // Assuming audio duration retrieval via a library or pre-known metadata
    return await _audioPlayer.getDuration() ?? 0; // Returns duration in milliseconds
  }

  Future<List<Map<String, dynamic>>> getMindfulnessCues(int sessionId) async {
    final List<Map<String, dynamic>> cues = await _database?.query(
          'cues',
          where: 'session_id = ?',
          whereArgs: [sessionId],
        ) ?? [];
    return cues;
  }
}
