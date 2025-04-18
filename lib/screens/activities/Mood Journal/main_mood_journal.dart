import 'package:flutter/material.dart';
import '../../../storage.dart';
import 'mood_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MoodJournal());
}

class MoodJournal extends StatelessWidget {

  const MoodJournal({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Journal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MoodSelectionScreen(),
    );
  }
}
