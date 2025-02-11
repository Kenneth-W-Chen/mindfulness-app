import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class EmotionExplorer extends StatefulWidget {
  @override
  _EmotionExplorerState createState() => _EmotionExplorerState();
}

class _EmotionExplorerState extends State<EmotionExplorer> {
  final List<Map<String, String>> emotions = [
    {
      'name': 'Happy',
      'description': 'You feel joyful and full of energy!',
      'audioUrl': 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
      'activity': 'Try a gratitude journal'
    },
    {
      'name': 'Sad',
      'description': 'It’s okay to feel sad. It means something matters to you.',
      'audioUrl': 'https://www.learningcontainer.com/wp-content/uploads/2020/02/ImperialMarch.mp3',
      'activity': 'Try deep breathing and journaling'
    },
    {
      'name': 'Angry',
      'description': 'Feeling mad? Let’s find a way to release that emotion safely.',
      'audioUrl': 'https://www.learningcontainer.com/wp-content/uploads/2020/02/CantinaBand.mp3',
      'activity': 'Try progressive muscle relaxation'
    },
    {
      'name': 'Anxious',
      'description': 'You may feel worried. Let’s calm our thoughts.',
      'audioUrl': 'https://www.learningcontainer.com/wp-content/uploads/2020/02/PinkPanther.mp3',
      'activity': 'Try a short guided meditation'
    }
  ];

  final AudioPlayer _audioPlayer = AudioPlayer();

  void _playAudio(String url) async {
    try {
      final player = AudioPlayer();
      if (kIsWeb) {
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setSource(UrlSource(url));
        await player.resume(); // For Web
      } else {
        await player.play(UrlSource(url));
      }
    } catch (e) {
      print("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Emotion Explorer")),
      body: ListView.builder(
        itemCount: emotions.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(emotions[index]['name']!),
              subtitle: Text(emotions[index]['description']!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmotionDetailPage(emotion: emotions[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class EmotionDetailPage extends StatelessWidget {
  final Map<String, String> emotion;
  final AudioPlayer _audioPlayer = AudioPlayer();

  EmotionDetailPage({required this.emotion});

  void _playAudio() async {
    await _audioPlayer.play(UrlSource(emotion['audioUrl']!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(emotion['name']!)),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(emotion['description']!, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text("Suggested Activity:", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(emotion['activity']!),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Play Audio Guide"),
              onPressed: _playAudio,
            ),
          ],
        ),
      ),
    );
  }
}
