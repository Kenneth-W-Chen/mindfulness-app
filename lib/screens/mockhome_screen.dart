import 'package:flutter/material.dart';
import 'activities/twilight_alley_intro.dart'; // Updated import path
import 'shared/mock_settings.dart'; // Import for the settings screen

class MockHomeScreen extends StatelessWidget {
  const MockHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore CalmQuest Islands'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Action for back button
          },
        ),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActivityCard(
              context,
              color: Colors.transparent,
              title: 'Welcome to CalmQuest!',
              description: 'Embark on a mindfulness journey!',
              icon: Icons.wb_sunny,
              gradient: LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildActivityCard(
              context,
              color: Colors.deepPurpleAccent,
              title: 'Misty Mountain',
              description: 'Exercise your breathing.',
              icon: Icons.terrain,
            ),
            _buildActivityCard(
              context,
              color: Colors.deepPurpleAccent,
              title: 'Serene Beach',
              description: 'Relax with guided visualizations.',
              icon: Icons.beach_access,
            ),
            _buildActivityCard(
              context,
              color: Colors.deepPurpleAccent,
              title: 'Tranquil Forest',
              description: 'Find calm with nature sounds.',
              icon: Icons.nature,
            ),
            _buildActivityCard(
              context,
              color: Colors.deepPurpleAccent,
              title: 'Twilight Alley',
              description: 'Take some time to reflect.',
              icon: Icons.nightlight_round,
              onTapCallback: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TwilightAlleyIntro(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (index == 2) {
            // Navigate to the settings page when the "Settings" button is pressed
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MockSettings()),
            );
          }
        },
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context,
      {required Color color,
        required String title,
        required String description,
        required IconData icon,
        Gradient? gradient,
        VoidCallback? onTapCallback}) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.white,
            size: 40,
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          onTap: onTapCallback,
        ),
      ),
    );
  }
}
