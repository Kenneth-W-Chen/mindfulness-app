import 'package:calm_quest/screens/activities/pos_affirm_activity.dart';
import 'package:flutter/material.dart';
import 'screens/shared/activity_widget.dart';
import 'screens/activities/Mood Journal/mood_selection_screen.dart';
import 'screens/activities/mellowmazeintro.dart';

class TranquilForestLandingPage extends StatelessWidget {
  const TranquilForestLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tranquil Forest',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.teal[800],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[900]!, Colors.teal[400]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Tranquil Forest!',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Explore our calming activities:',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              activityCard('Mood Journal', context, Icons.book,
                  'Talk about how you feel today',
                  builder: (context) => MoodSelectionScreen(),
                  // colors
                  cardColor: Colors.white.withOpacity(0.9),
                  shadowColor: Colors.black.withOpacity(0.3),
                  iconBackgroundColor: Colors.teal[700],
                  iconColor: Colors.white,
                  textColor: Colors.teal[700],
                  subTextColor: Colors.teal[600]),
              activityCard('Mellow Maze', context, Icons.blur_circular,
                  'Traverse the maze to clear your mind.',
                  builder: (context) => const MellowMazeIntro(),
                  cardColor: Colors.white.withOpacity(0.9),
                  shadowColor: Colors.black.withOpacity(0.3),
                  iconBackgroundColor: Colors.teal[700],
                  iconColor: Colors.white,
                  textColor: Colors.teal[700],
                  subTextColor: Colors.teal[600]),
              activityCard('Postive Power Ups', context, Icons.book,
                  'Ground yourself with positive affirmations',
                  builder: (context) => const QuoteScreen(),
                  // colors
                  cardColor: Colors.white.withOpacity(0.9),
                  shadowColor: Colors.black.withOpacity(0.3),
                  iconBackgroundColor: Colors.teal[700],
                  iconColor: Colors.white,
                  textColor: Colors.teal[700],
                  subTextColor: Colors.teal[600]),
            ],
          ),
        ),
      ),
    );
  }
}
