import 'package:flutter/material.dart';
import 'mood_selection_screen.dart';

void main() {
  runApp(const MoodJournalApp());
}

class MoodJournalApp extends StatelessWidget {
  const MoodJournalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Journal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MoodSelectionScreen(),
    );
  }
}
