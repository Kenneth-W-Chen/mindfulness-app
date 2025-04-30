<<<<<<< HEAD
import 'package:calm_quest/MistyMountainLandingPage.dart';
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
=======
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';

import 'theme_notifier.dart';
import 'MistyMountainLandingPage.dart';
import 'serene_beach_page.dart';
import 'TranquilForestlandingpage.dart';
import 'custom_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool soundEnabled = true;

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void playChime(String fileName) async {
    if (!soundEnabled) return;
    final player = AudioPlayer();
    await player.play(AssetSource('sounds/$fileName'));
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    final List<Color> gradientColors = isDark
        ? [const Color(0xFF141E30), const Color(0xFF1A237E)]
        : [const Color(0xFFFFD1FF), const Color.fromARGB(255, 140, 128, 219)];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              getGreeting(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            Text(
              'CalmQuest Islands',
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              soundEnabled ? Icons.music_note : Icons.music_off,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                soundEnabled = !soundEnabled;
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Twinkling stars background
          Positioned.fill(
            child: Stack(
              children: [
                Lottie.asset(
                  'assets/animations/twinkle_stars.json',
                  fit: BoxFit.cover,
                  repeat: true,
                ),
                Opacity(
                  opacity: 0.3,
                  child: Lottie.asset(
                    'assets/animations/twinkle_stars.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
>>>>>>> local-version
                ),
              ],
            ),
          ),
<<<<<<< HEAD
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF80D8FF),
                Color(0xFF40C4FF)
              ], // Light blue gradient
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
          mainAxisAlignment:
              MainAxisAlignment.spaceEvenly, // Spread out the tiles
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
                    builder: (context) =>  MistyMountainLandingPage(),
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
                    builder: (context) =>  SereneBeachPage(),
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
                    builder: (context) =>  TranquilForestLandingPage(),
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
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(4, 4),
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
=======

          // Gradient background overlay (dynamic)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Island content cards
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    child: _buildIslandImageCard(
                      title: 'Misty Mountain',
                      description: 'Guided visualizations in the clouds.',
                      imagePath: 'assets/images/mistymount.png',
                      soundFile: 'misty_mountain.mp3',
                      navigateTo: MistyMountainLandingPage(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 800),
                    child: _buildIslandImageCard(
                      title: 'Serene Beach',
                      description: 'Let the waves guide your mind.',
                      imagePath: 'assets/images/beach.png',
                      soundFile: 'serene_beach.mp3',
                      navigateTo: SereneBeachPage(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FadeInUp(
                    duration: const Duration(milliseconds: 1000),
                    child: _buildIslandImageCard(
                      title: 'Tranquil Forest',
                      description: 'Nature sounds to calm your soul.',
                      imagePath: 'assets/images/tranforest.png',
                      soundFile: 'tranquil_forest.mp3',
                      navigateTo: TranquilForestLandingPage(),
>>>>>>> local-version
                    ),
                  ),
                ],
              ),
            ),
<<<<<<< HEAD
          ],
=======
          ),

          // Bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavigationBar(
              selectedIndex: 0,
              onItemTapped: (index) {
                switch (index) {
                  case 1:
                    Navigator.pushReplacementNamed(context, '/todays_activities');
                    break;
                  case 2:
                    Navigator.pushReplacementNamed(context, '/achievements');
                    break;
                  case 3:
                    Navigator.pushReplacementNamed(context, '/settings');
                    break;
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIslandImageCard({
    required String title,
    required String description,
    required String imagePath,
    required String soundFile,
    required Widget navigateTo,
  }) {
    return InkWell(
      onTap: () async {
        playChime(soundFile);
        await Future.delayed(const Duration(milliseconds: 300));
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => navigateTo),
        );
      },
      borderRadius: BorderRadius.circular(24),
      splashColor: Colors.white24,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: DecorationImage(
              image: AssetImage(imagePath),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.35),
                BlendMode.darken,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
>>>>>>> local-version
        ),
      ),
    );
  }
}
<<<<<<< HEAD
=======








>>>>>>> local-version
