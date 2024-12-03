import 'package:flutter/material.dart';
import 'screens/shared/activity_widget.dart';
import 'screens/activities/meditation_station.dart';
import 'screens/activities/twilight_alley_intro.dart';
import 'screens/activities/calmingcliffintro.dart';

class TranquilForestLandingPage extends StatelessWidget {
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

              // Activity for Meditation Station
              activityCard('Meditation Station', context, Icons.headset,
                  'Listen to calming sounds and nature noises.',
                  builder: (context) => MeditationStation(),
                // colors
                cardColor: Colors.white.withOpacity(0.9), shadowColor: Colors.black.withOpacity(0.3), iconBackgroundColor: Colors.teal[700],iconColor:  Colors.white, textColor: Colors.teal[700], subTextColor: Colors.teal[600]
              ),

              // Activity for Goal Setting
              activityCard('Twilight Alley', context, Icons.flag,
                  'Journal some of your thoughts and track your mood.',
                  builder: (context) => TwilightAlleyIntro(),
                  // colors
                  cardColor: Colors.white.withOpacity(0.9), shadowColor: Colors.black.withOpacity(0.3), iconBackgroundColor: Colors.teal[700],iconColor:  Colors.white, textColor: Colors.teal[700], subTextColor: Colors.teal[600]
              ),

              // Activity for calming visualization
              activityCard('Calming Cliff', context, Icons.landscape,
                  'Calm yourself and realize that there is so much out there.',
                  builder: (context) => CalmingCliffsIntro(),
                  // colors
                  cardColor: Colors.white.withOpacity(0.9), shadowColor: Colors.black.withOpacity(0.3), iconBackgroundColor: Colors.teal[700],iconColor:  Colors.white, textColor: Colors.teal[700], subTextColor: Colors.teal[600]
              ),

            ],
          ),
        ),
      ),
    );
  }
}
