import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'screens/todays_activities.dart';

void main() {
  runApp(const CalmQuestApp());
}

class CalmQuestApp extends StatelessWidget {
  const CalmQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/todays_activities': (context)=> const TodaysActivitiesScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}