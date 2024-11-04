import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';  // For debugPrint

class MindfulnessAudioManager {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool loop = false;
  double volume = 1.0;

  // Initialize audio player settings
  Future<void> initializeAudio() async {
    // Use storage.dart if there's any database interaction required
    debugPrint("Audio Manager initialized.");
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
    debugPrint("Playing audio: $audioFile");
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    isPlaying = false;
    debugPrint("Audio paused.");
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
    isPlaying = true;
    debugPrint("Audio resumed.");
  }

  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    isPlaying = false;
    debugPrint("Audio stopped.");
  }

  Future<void> adjustVolume(double level) async {
    volume = level.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(volume);
    debugPrint("Volume set to ${(volume * 100).toStringAsFixed(0)}%");
  }

  // Dummy function to demonstrate preference fetching
  Future<void> loadVolumeFromPreferences() async {
    // Example: Assuming volume is fetched from storage.dart preferences
    // volume = await Storage.getVolumePreference();
    debugPrint("Volume loaded from preferences: $volume");
  }
}
