import 'package:calm_quest/screens/activities/pos_affirm_activity.dart';
import 'package:flutter/material.dart';
import 'screens/shared/activity_widget.dart';
import 'screens/activities/Mood Journal/mood_selection_screen.dart';
import 'screens/activities/mellowmazeintro.dart';

class TranquilForestLandingPage extends StatelessWidget {
  const TranquilForestLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> activities = [
      {
        'title': 'Mood Journal',
        'icon': Icons.book,
        'description':
            'Reflect on your emotions and process feelings, recognize patterns, and build emotional awareness.',
        'builder': (context) => MoodSelectionScreen(),
      },
      {
        'title': 'Mellow Maze',
        'icon': Icons.blur_circular,
        'description':
            'Slow down, focus on the present, and clear your thoughts in a gentle, meditative way.',
        'builder': (context) => const MellowMazeIntro(),
      },
      {
        'title': 'Positive Power Ups',
        'icon': Icons.bolt,
        'description':
            'Recharge your mind with uplifting affirmations and remind you of your inner strengths.',
        'builder': (context) => const QuoteScreen(),
      },
    ];

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
        backgroundColor: const Color.fromARGB(255, 98, 50, 130),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 65, 35, 94),
              const Color.fromARGB(255, 150, 80, 180),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Tranquil Forest!',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              const Text(
                'Explore our calming activities:',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
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
                              image: AssetImage('assets/images/forest.png'),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.4),
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
                                const Color.fromARGB(255, 26, 9, 38),
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
