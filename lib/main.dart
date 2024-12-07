import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'screens/todays_activities.dart';

import 'Mood Journal/mood_selection_screen.dart'; // Import Mood Selection Screen
import 'storage.dart'; // Import the Storage class

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database storage
  final storage = await Storage.create();

  runApp(CalmQuestApp(storage: storage));
}

class CalmQuestApp extends StatelessWidget {
  final Storage storage;

  const CalmQuestApp({super.key, required this.storage});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),

        '/todays_activities': (context) => const TodaysActivitiesScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/mood_journal': (context) => MoodSelectionScreen(storage: storage), // Pass Storage instance
      },
    );
  }
}

