import 'package:flutter/material.dart';
import 'screens/shared/activity_widget.dart';
import 'screens/activities/meditation_station.dart';
import 'screens/activities/twilight_alley_intro.dart';
import 'screens/activities/calmingcliffintro.dart';

class MistyMountainLandingPage extends StatelessWidget {
  const MistyMountainLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Meditation Station',
        'icon': Icons.headset,
        'description':
            "Take a few moments to escape from the daily noise and find your inner calm, with guided meditations.",
        'builder': (context) => const MeditationStation(),
      },
      {
        'title': 'Twilight Alley',
        'icon': Icons.flag,
        'description':
            "Track your emotions, write down your reflections, and explore your inner world in a peaceful setting.",
        'builder': (context) => const TwilightAlleyIntro(),
      },
      {
        'title': 'Calming Cliff',
        'icon': Icons.landscape,
        'description':
            "View the stunning sight that offers a moment to reconnect with yourself and the vastness of nature.",
        'builder': (context) => const CalmingCliffsIntro(),
      }
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Misty Mountain',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 56, 130, 107),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(104, 7, 153, 87),
              const Color.fromARGB(206, 0, 128, 128),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center alignment
            children: [
              const Text(
                'Welcome to Misty Mountain!',
                style: TextStyle(
                  fontSize: 32, // Larger font size for prominence
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center, // Center text
              ),
              const SizedBox(height: 40),
              const Text(
                'Explore our calming activities:',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center, // Center text
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView(
                  children: activities.map((activity) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  'assets/images/mountain.png'), // Background image
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(
                                    0.4), // Reduced opacity for better visibility
                                BlendMode.dstATop,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 5,
                                spreadRadius: 2,
                                offset: const Offset(3, 3),
                              ),
                            ],
                          ),
                          child: activityCard(
                            activity['title'],
                            context,
                            activity['icon'],
                            activity['description'],
                            builder: activity['builder'],
                            cardColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            iconBackgroundColor:
                                const Color.fromARGB(255, 7, 47, 16),
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            subTextColor: Colors.white70,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
