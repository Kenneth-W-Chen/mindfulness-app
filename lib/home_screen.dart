import 'package:flutter/material.dart';
import 'serene_beach_page.dart';
import 'placeholder_screen.dart';
import 'TranquilForestlandingpage.dart';
import 'custom_bottom_navigation_bar.dart'; // Correct import for the navigation bar

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Light blue background
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFFD6C8FF), // Soft lavender
              Color(0xFFFFE082), // Soft yellow
              Color(0xFFC8E6C9), // Mint green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: const Text(
            'Explore CalmQuest Islands',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Chewy',
              color: Colors.white, // Necessary for ShaderMask to apply color
              shadows: [
                Shadow(
                  color: Colors.black38, // Subtle shadow for better readability
                  blurRadius: 4.0,
                  offset: Offset(1, 2),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF80D8FF), Color(0xFF40C4FF)], // Light blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Spread out the tiles
          children: [
            _buildIslandTile(
              title: 'Misty Mountain',
              icon: Icons.terrain,
              description: 'Relax with guided visualizations.',
              startColor: const Color(0xFF8E24AA),
              endColor: const Color(0xFFBA68C8),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlaceholderScreen(
                      message: 'Misty Mountain - Feature Coming Soon!',
                    ),
                  ),
                );
              },
            ),
            _buildIslandTile(
              title: 'Serene Beach',
              icon: Icons.beach_access,
              description: 'Let the waves guide you to inner peace',
              startColor: const Color(0xFFFFC107),
              endColor: const Color(0xFFFFE082),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SereneBeachPage(),
                  ),
                );
              },
            ),
            _buildIslandTile(
              title: 'Tranquil Forest',
              icon: Icons.nature,
              description: 'Find calm with nature sounds.',
              startColor: const Color(0xFF4CAF50),
              endColor: const Color(0xFF81C784),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TranquilForestLandingPage(),
                  ),
                );
              },
            ),
            _buildIslandTile(
  title: 'Emotion Explorer',
  icon: Icons.emoji_emotions,
  description: 'Discover and track your emotions',
  startColor: const Color(0xFFFFA726), // Orange
  endColor: const Color(0xFFFFCC80),   // Light Orange
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmotionExplorer(), // Navigate to Emotion Explorer
      ),
    );
  },
),

          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 0,
        onItemTapped: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/todays_activities');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/achievements');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
      ),
    );
  }

  Widget _buildIslandTile({
    required String title,
    required IconData icon,
    required String description,
    required Color startColor,
    required Color endColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        height: 160, // Increased tile height to fill the page evenly
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Chewy',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Chewy',
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
