import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../storage.dart';
import '../../AudioManager.dart';
import 'package:path/path.dart' as path;
import 'dart:developer';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen(
      {Key? key,
        required String this.audioFilePath,
        required Storage this.storage})
      : super(key: key);
  final String audioFilePath;
  final Storage storage;

  @override
  _AudioPlayerScreenState createState() =>
      _AudioPlayerScreenState(storage: storage, audioFilePath: audioFilePath);
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  late AudioManager _audioManager;
  final Storage storage;
  bool isPlaying = false;
  final String audioFilePath;

  _AudioPlayerScreenState(
      {required Storage this.storage, required String this.audioFilePath});

  late Timer completionTimer;

  @override
  void initState() {
    super.initState();
    _audioManager = AudioManager(storage);
    asyncInit();
  }

  Future<void> asyncInit() async {
    DateTime? completion_date = (await storage.getActivityLogs(
        [ActivityName.meditation_station]))[ActivityName.meditation_station]![0]
    ['completion_date'] as DateTime?;
    DateTime now = DateTime.now().toUtc();
    now = DateTime.utc(now.year, now.month, now.day);
    if (completion_date == null || now.isAfter(completion_date)) {
      completionTimer = Timer(Duration(seconds: 30), () {
        storage.addActivityLog(ActivityName.meditation_station, audioFilePath);
      });
    }
    _audioManager.playAudio(audioFilePath, loop: true);
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
      appBar: AppBar(
        title: const Text("Audio Player"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (_audioManager.audioPlayer.state == PlayerState.playing) {
                  _audioManager.pauseAudio();
                } else {
                  _audioManager.resumeAudio();
                }
                setState(() {

                });
              },
              child: _audioManager.audioPlayer.state == PlayerState.paused ? const Text('Resume'):const Text('Pause'),
            ),
            ElevatedButton(
              onPressed: _audioManager.stopAudio,
              child: const Text("Stop"),
            ),
          ],
        ),
      ),
    );
  }
}

class MeditationStation extends StatefulWidget {
  const MeditationStation({super.key, required this.title});

  final String title;

  @override
  State<MeditationStation> createState() => _MeditationStationState();
}

class _MeditationStationState extends State<MeditationStation> {
  late String _dropdownValue;
  late Storage storage;
  List<String>? audioList;

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
    storage = await Storage.create();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xffEBEDFE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: DropdownButton<String>(
                  value: _dropdownValue,
                  icon: const Icon(Icons.menu),
                  style: const TextStyle(color: Colors.black),
                  underline: Container(
                    height: 2,
                    color: Colors.black,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _dropdownValue = newValue!;
                    });
                  },
                  items: audioList?.map<DropdownMenuItem<String>>((String val) {
                    return DropdownMenuItem(
                        value: val,
                        child: Text(path
                            .basenameWithoutExtension(val)
                            .replaceAll('_', ' ')));
                  }).toList() ??
                      [],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AudioPlayerScreen(
                        audioFilePath: _dropdownValue,
                        storage: storage,
                      )),
                );
              },
              child: const Text("Go to Audio Player"),
            ),
          ],
        ),
      ),
    );
  }
}
