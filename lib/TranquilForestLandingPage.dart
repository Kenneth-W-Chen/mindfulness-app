import 'package:flutter/material.dart';
import 'screens/activities/meditation_station.dart';
import 'screens/activities/twilight_alley_intro.dart';

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
              _activityCard('Meditation Station', context, Icons.headset,
                  'Listen to calming sounds and nature noises.', builder: (context)=> MeditationStation()),

              // Activity for Goal Setting
              _activityCard('Twilight Alley', context, Icons.flag,
                  'Journal some of your thoughts', builder: (context)=> TwilightAlleyIntro()),
            ],
          ),
        ),
      ),
    );
  }

  // Method to create activity cards with placeholders for future functionality
  Widget _activityCard(String activityName, BuildContext context, IconData icon,
      String description,
      {Widget Function(BuildContext buildcontext)? builder = null}) {
    return GestureDetector(
      onTap: builder == null? () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$activityName feature is under construction!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }:() {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: builder
            ));
      },
      child: Card(
        color: Colors.white.withOpacity(0.9),
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.3),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.teal[700],
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          title: Text(
            activityName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal[700],
              letterSpacing: 1.0,
            ),
          ),
          subtitle: Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.teal[600],
            ),
          ),
        ),
      ),
    );
  }
}
