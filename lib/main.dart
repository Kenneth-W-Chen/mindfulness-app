import 'package:calm_quest/notifications.dart';
import 'package:flutter/material.dart';
import 'breathing_activity.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'screens/todays_activities.dart';
import 'TranquilForestlandingpage.dart'; // Correct file name
import 'serene_beach_page.dart';
import 'placeholder_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(const CalmQuestApp());
  notifications.init();
}

class CalmQuestApp extends StatelessWidget {
  const CalmQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calm Quest App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/todays_activities': (context)=> const TodaysActivitiesScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/breathing_activity': (context) => const BreathingActivity(),
        '/tranquil_forest': (context) => TranquilForestLandingPage(), // Correct reference
        '/serene_beach': (context) =>  SereneBeachPage(),
        '/placeholder': (context) => const PlaceholderScreen(
              message: 'Feature Under Construction',
            ),
      },
    );
  }
}