import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';  // For debugPrint
import 'storage.dart';  // For database interactions

class AudioManager {
  final AudioPlayer audioPlayer = AudioPlayer();
  final Storage storage;  // Made public by removing the underscore
  bool loop = false;
  double masterVolume = 1.0, musicVolume = 1.0, soundFxVolume = 1.0;

  // Constructor with initialization logic
  AudioManager(this.storage) {
    _initializeAudio();
  }

  // Initialize audio preferences and setup using Storage instance
  Future<void> _initializeAudio() async {
    try {
      // Fetch volume preference from storage
      Map<PreferenceName, int>? preferences = await storage.getPreferences([PreferenceName.master_volume, PreferenceName.music_volume, PreferenceName.sound_fx_volume]);
      if (preferences != null && preferences.containsKey(PreferenceName.master_volume)) {
        masterVolume = preferences[PreferenceName.master_volume]! / 10.0;
        musicVolume = preferences[PreferenceName.music_volume]! / 10.0;
        soundFxVolume = preferences[PreferenceName.sound_fx_volume]! /10.0;
      }
      if (kDebugMode) {
        debugPrint("Audio Manager initialized with volume: $masterVolume");
      }
    } catch (error) {
      debugPrint("Error initializing audio preferences: $error");
    }
  }

  Future<void> initializeAudioSession(int sessionId, String name) async {
    // Use storage to handle session initialization
    await storage.insertSession(sessionId, name);
    if (kDebugMode) {
      debugPrint("Session $sessionId initialized with name: $name.");
    }
  }

  Future<void> playAudio(String audioFile, {bool loop = false}) async {
    await audioPlayer.setVolume(masterVolume * (isMusicFile(audioFile)? musicVolume: soundFxVolume));

    // Set the audio source as an asset file
    await audioPlayer.setSource(AssetSource(audioFile));

    // Set looping if required
    await audioPlayer.setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.stop);

    // Start playing the audio
    await audioPlayer.resume();
    if (kDebugMode) {
      debugPrint("Playing audio: $audioFile with loop set to $loop");
    }
  }
  
  bool isMusicFile(String audioFile){
      return audioFile.startsWith('assets/audio/activity_one');
  }

  Future<void> pauseAudio() async {
    await audioPlayer.pause();
    if (kDebugMode) {
      debugPrint("Audio paused.");
    }
  }

  Future<void> resumeAudio() async {
    await audioPlayer.resume();
    if (kDebugMode) {
      debugPrint("Audio resumed.");
    }
  }

  Future<void> stopAudio() async {
    await audioPlayer.stop();
    if (kDebugMode) {
      debugPrint("Audio stopped.");
    }
  }

  Future<void> adjustVolume(double level) async {
    masterVolume = level.clamp(0.0, 1.0);
    await audioPlayer.setVolume(masterVolume);
    try {
      // Save volume preference in storage
      await storage.updatePreferences({PreferenceName.master_volume: (masterVolume * 100).round()});
      if (kDebugMode) {
        debugPrint("Volume set to ${(masterVolume * 100).toStringAsFixed(0)}% and saved to preferences.");
      }
    } catch (error) {
      debugPrint("Error saving volume preference: $error");
    }
  }

  Future<void> addMindfulnessCue(int sessionId, int timeSec, String message) async {
    // Insert cue using storage
    await storage.insertCue(sessionId, timeSec, message);
    if (kDebugMode) {
      debugPrint("Cue added for session $sessionId at $timeSec seconds: $message");
    }
  }

  Future<int> fetchAudioDuration(String audioFile) async {
    // Set the audio source without playing it
    await audioPlayer.setSource(AssetSource(audioFile));

    // Wait briefly to ensure the audio file is loaded
    await Future.delayed(Duration(milliseconds: 100));

    // Now retrieve the duration
    Duration? duration = await audioPlayer.getDuration();
    return duration?.inMilliseconds ?? 0; // Convert Duration to milliseconds, or return 0 if null
  }

  Future<List<Map<String, dynamic>>> getMindfulnessCues(int sessionId) async {
    // Fetch cues for a session using storage
    return await storage.getCuesForSession(sessionId) ?? [];
  }

  // Dispose of audio resources
  Future<void> dispose() async {
    await audioPlayer.dispose();
    if (kDebugMode) {
      debugPrint("Audio Manager disposed and resources released.");
    }
  }
}
