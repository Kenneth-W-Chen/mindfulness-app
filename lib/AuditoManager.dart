import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';  // For debugPrint
import 'storage.dart';  // Assumed to handle all database interactions

class MindfulnessAudioManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool loop = false;
  double volume = 1.0;

  // Constructor with initialization logic
  MindfulnessAudioManager() {
    _initializeAudio();
  }

  // Initialize audio preferences and setup using storage.dart
  Future<void> _initializeAudio() async {
    volume = await Storage.getVolumePreference() ?? 1.0;  // Load volume from preferences
    debugPrint("Audio Manager initialized with volume: $volume");
  }

  Future<void> initializeAudioSession(int sessionId, String name) async {
    // Use storage.dart to handle session initialization
    await Storage.insertSession(sessionId, name);
    debugPrint("Session $sessionId initialized with name: $name.");
  }

  Future<void> playAudio(String audioFile, {bool loop = false}) async {
    this.loop = loop;
    await _audioPlayer.setVolume(volume);
    await _audioPlayer.play(AssetSource(audioFile), isLocal: true);

    _audioPlayer.onPlayerComplete.listen((_) {
      if (loop) {
        playAudio(audioFile, loop: true);  // Re-trigger play for looping
      }
    });

    debugPrint("Playing audio: $audioFile");
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    debugPrint("Audio paused.");
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
    debugPrint("Audio resumed.");
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    debugPrint("Audio stopped.");
  }

  Future<void> adjustVolume(double level) async {
    volume = level.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(volume);
    await Storage.setVolumePreference(volume);  // Save volume preference through storage.dart
    debugPrint("Volume set to ${(volume * 100).toStringAsFixed(0)}% and saved to preferences.");
  }

  Future<void> addMindfulnessCue(int sessionId, int timeSec, String message) async {
    // Insert cue using storage.dart
    await Storage.insertCue(sessionId, timeSec, message);
    debugPrint("Cue added for session $sessionId at $timeSec seconds: $message");
  }

  Future<int> fetchAudioDuration(String audioFile) async {
    return await _audioPlayer.getDuration() ?? 0; // Returns duration in milliseconds
  }

  Future<List<Map<String, dynamic>>> getMindfulnessCues(int sessionId) async {
    // Fetch cues for a session using storage.dart
    return await Storage.getCuesForSession(sessionId) ?? [];
  }
}
