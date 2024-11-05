import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';  // For debugPrint
import 'storage.dart';  // For database interactions

class AudioManager {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool loop = false;
  double volume = 1.0;

  // Constructor with initialization logic
  AudioManager() {
    _initializeAudio();
  }

  // Initialize audio preferences and setup using storage.dart
  Future<void> _initializeAudio() async {
    try {
      // Fetch volume preference from storage
      Map<PreferenceName, int>? preferences = await Storage.getPreferences([PreferenceName.master_volume]);
      if (preferences != null && preferences.containsKey(PreferenceName.master_volume)) {
        volume = preferences[PreferenceName.master_volume]! / 100.0;  // Assuming volume is stored as an integer percentage
      }
      debugPrint("Audio Manager initialized with volume: $volume");
    } catch (error) {
      debugPrint("Error initializing audio preferences: $error");
    }
  }

  Future<void> initializeAudioSession(int sessionId, String name) async {
    // Use storage.dart to handle session initialization
    await Storage.insertSession(sessionId, name);
    debugPrint("Session $sessionId initialized with name: $name.");
  }

  Future<void> playAudio(String audioFile, {bool loop = false}) async {
    this.loop = loop;
    await audioPlayer.setVolume(volume);
    await audioPlayer.play(AssetSource(audioFile), isLocal: true);

    audioPlayer.onPlayerComplete.listen((_) {
      if (loop) {
        playAudio(audioFile, loop: true);  // Re-trigger play for looping
      }
    });

    debugPrint("Playing audio: $audioFile");
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
    debugPrint("Audio paused.");
  }

  Future<void> resumeAudio() async {
    await audioPlayer.resume();
    debugPrint("Audio resumed.");
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    debugPrint("Audio stopped.");
  }

  Future<void> adjustVolume(double level) async {
    volume = level.clamp(0.0, 1.0);
    await audioPlayer.setVolume(volume);
    try {
      // Save volume preference in storage
      await Storage.updatePreferences({PreferenceName.master_volume: (volume * 100).round()});
      debugPrint("Volume set to ${(volume * 100).toStringAsFixed(0)}% and saved to preferences.");
    } catch (error) {
      debugPrint("Error saving volume preference: $error");
    }
  }

  Future<void> addMindfulnessCue(int sessionId, int timeSec, String message) async {
    // Insert cue using storage.dart
    await Storage.insertCue(sessionId, timeSec, message);
    debugPrint("Cue added for session $sessionId at $timeSec seconds: $message");
  }

  Future<int> fetchAudioDuration(String audioFile) async {
    return await audioPlayer.getDuration() ?? 0; // Returns duration in milliseconds
  }

  Future<List<Map<String, dynamic>>> getMindfulnessCues(int sessionId) async {
    // Fetch cues for a session using storage.dart
    return await Storage.getCuesForSession(sessionId) ?? [];
  }
   // Dispose of audio resources
  Future<void> dispose() async {
    await audioPlayer.dispose();
    debugPrint("Audio Manager disposed and resources released.");
  }
}
