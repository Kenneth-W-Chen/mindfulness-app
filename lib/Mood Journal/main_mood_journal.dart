import 'package:flutter/material.dart';
import 'package:untitled/storage.dart'; // Update this import path based on your project structure
import 'mood_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database storage
  final storage = await Storage.create();

  runApp(MoodJournal(storage: storage));
}

class MoodJournal extends StatelessWidget {
  final Storage storage;

  const MoodJournal({Key? key, required this.storage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Journal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MoodSelectionScreen(storage: storage),
    );
  }
}
