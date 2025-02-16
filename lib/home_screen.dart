import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/animation.dart';
import 'serene_beach_page.dart';
import 'placeholder_screen.dart';
import 'TranquilForestlandingpage.dart';
import 'custom_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = _createFloatingAnimationController();
    _controller2 = _createFloatingAnimationController();
    _controller3 = _createFloatingAnimationController();
  }

  AnimationController _createFloatingAnimationController() {
    return AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      body: Column(
        children: [
          const SizedBox(height: 50),
          const Center(
            child: Text(
              'Welcome to CalmQuest',
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Chewy',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFloatingIslandTile(
                  title: 'Misty Mountain',
                  description: 'Guided visualizations for calmness.',
                  startColor: const Color(0xFF5E35B1),
                  endColor: const Color(0xFF9575CD),
                  icon: Icons.terrain,
                  controller: _controller1,
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
                const SizedBox(height: 50),
                _buildFloatingIslandTile(
                  title: 'Serene Beach',
                  description: 'Let the waves guide you to peace.',
                  startColor: const Color(0xFF039BE5),
                  endColor: const Color(0xFF81D4FA),
                  icon: Icons.beach_access,
                  controller: _controller2,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SereneBeachPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 50),
                _buildFloatingIslandTile(
                  title: 'Tranquil Forest',
                  description: 'Relax with soothing nature sounds.',
                  startColor: const Color(0xFF388E3C),
                  endColor: const Color(0xFF81C784),
                  icon: Icons.nature,
                  controller: _controller3,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TranquilForestLandingPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 0,
        onItemTapped: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/achievements');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/settings');
          }
        },
      ),
    );
  }

  Widget _buildFloatingIslandTile({
    required String title,
    required String description,
    required Color startColor,
    required Color endColor,
    required IconData icon,
    required AnimationController controller,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 10 * sin(controller.value * pi * 2)),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [startColor, endColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(4, 8),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 50, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Chewy',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}







