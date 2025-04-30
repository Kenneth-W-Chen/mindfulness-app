import 'package:calm_quest/achievements_system.dart';
import 'package:calm_quest/storage.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'breathing_activity.dart'; // Importing the Breathing Activity Page

class SereneBeachPage extends StatelessWidget {
  SereneBeachPage({super.key}){
=======
import 'breathing_activity.dart';

class SereneBeachPage extends StatelessWidget {
  SereneBeachPage({super.key}) {
>>>>>>> local-version
    AchievementsSystem.updateAchievementCondition(Achievement.Well_Rounded, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
<<<<<<< HEAD
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/serene_beach_page.png'),
=======
          // Beach background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/serene_beach_background.png'), // ✅ Make sure this file exists
>>>>>>> local-version
                fit: BoxFit.cover,
              ),
            ),
          ),
<<<<<<< HEAD
          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
          // Content overlay
          Column(
            children: [
              const SizedBox(height: 80), // Top padding for the title
              const Text(
                'Welcome to Serene Beach',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Chewy',
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 6.0,
                      color: Colors.black38,
                      offset: Offset(2, 2),
=======

          // Overlay gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Welcome to Serene Beach',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontFamily: 'Chewy',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black54,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Feeling the sea breeze?\nTake a moment to breathe and relax.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BreathingActivity(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4AC1F2),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 36, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 12,
                        shadowColor: Colors.blueAccent.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Start Breathing Activity',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
>>>>>>> local-version
                    ),
                  ],
                ),
              ),
<<<<<<< HEAD
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BreathingActivity(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4AC1F2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 10,
                  ),
                  child: const Text(
                    'Start Breathing Activity',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
=======
            ),
>>>>>>> local-version
          ),
        ],
      ),
    );
  }
}
<<<<<<< HEAD
=======



>>>>>>> local-version
