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
                ),
              ],
            ),
          ),

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
                    ),
                  ),
                ],
              ),
            ),
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
        ),
      ),
    );
  }
}








