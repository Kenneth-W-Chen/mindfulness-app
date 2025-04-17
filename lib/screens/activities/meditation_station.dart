import 'dart:async';

import 'package:calm_quest/achievements_system.dart';
import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../storage.dart';
import '../../AudioManager.dart';
import 'package:path/path.dart' as path;

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen(
      {super.key, required this.audioFilePath});
  final String audioFilePath;

  @override
  _AudioPlayerScreenState createState() =>
      _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioManager _audioManager;
  bool isPlaying = false;
  bool _activityCompleted = false;

  _AudioPlayerScreenState();

  late Timer completionTimer;

  @override
  void initState() {
    super.initState();
    _audioManager = AudioManager(Storage.storage);
    asyncInit();
  }

  Future<void> asyncInit() async {
    DateTime? completionDate = (await Storage.storage.getActivityLogs(
            [ActivityName.values[1]]))[ActivityName.values[1]]![0]
        ['completion_date'] as DateTime?;
    DateTime now = DateTime.now().toUtc();
    now = DateTime.utc(now.year, now.month, now.day);
    if (completionDate == null || now.isAfter(completionDate)) {
      completionTimer = Timer(const Duration(seconds: 30), () {
        _activityCompleted = true;
        Storage.storage.addActivityLog(ActivityName.values[1], widget.audioFilePath);
        AchievementsSystem.updateAchievementCondition(Achievement.Breath_of_Fresh_Air, 1);
        setState(() {});
      });
    } else {
      completionTimer = Timer(const Duration(seconds: 30), () {
        _activityCompleted = true;
        setState(() {});
      });
    }
    _audioManager.playAudio(widget.audioFilePath, loop: true);
  }

  @override
  void dispose() {
    completionTimer.cancel();
    _audioManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: activityAppBar('Meditation Station', Colors.deepPurple[800]!,
            context, _activityCompleted),
        body: Container(
          decoration: BoxDecoration(color: Colors.deepPurple[600]),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_audioManager.audioPlayer.state ==
                        PlayerState.playing) {
                      _audioManager.pauseAudio();
                    } else {
                      _audioManager.resumeAudio();
                    }
                    setState(() {});
                  },
                  child: _audioManager.audioPlayer.state == PlayerState.paused
                      ? const Text('Resume')
                      : const Text('Pause'),
                ),
                ElevatedButton(
                  onPressed: _audioManager.stopAudio,
                  child: const Text("Stop"),
                ),
              ],
            ),
          ),
        ));
  }
}

class MeditationStation extends StatefulWidget {
  const MeditationStation({super.key});

  @override
  State<MeditationStation> createState() => _MeditationStationState();
}

class _MeditationStationState extends State<MeditationStation> {
  late String _dropdownValue;
  List<String>? audioList;
  bool _activityCompleted = false;

  @override
  void initState() {
    super.initState();
    _dropdownValue = '';
    asyncInit();
  }

  Future<void> asyncInit() async {
    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
// This returns a List<String> with all your images
    audioList = assetManifest
        .listAssets()
        .where((string) => string.startsWith("assets/audio/activity_one"))
        .toList();
    for (int i = 0; i < audioList!.length; i++) {
      audioList![i] = audioList![i].replaceAll('assets/', '');
    }
    _dropdownValue = audioList![0];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: activityAppBar('Meditation Station', Colors.deepPurple[800]!,
          context, _activityCompleted),
      body: Container(
        decoration: BoxDecoration(color: Colors.deepPurple[600]),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: DropdownButton<String>(
                    value: _dropdownValue,
                    icon: const Icon(Icons.menu),
                    style: const TextStyle(color: Colors.black),
                    underline: Container(
                      height: 2,
                      color: Colors.white,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        _dropdownValue = newValue!;
                      });
                    },
                    items:
                        audioList?.map<DropdownMenuItem<String>>((String val) {
                              return DropdownMenuItem(
                                  value: val,
                                  child: Text(path
                                      .basenameWithoutExtension(val)
                                      .replaceAll('_', ' ')));
                            }).toList() ??
                            [],
                    dropdownColor: Colors.deepPurpleAccent[100],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AudioPlayerScreen(
                              audioFilePath: _dropdownValue,
                            )),
                  ).then((value) {
                    _activityCompleted = value as bool || _activityCompleted;
                    setState(() {});
                  });
                },
                child: const Text("Go to Audio Player"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
