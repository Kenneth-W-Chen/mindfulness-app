<<<<<<< HEAD
// lib/custom_bottom_navigation_bar.dart
=======
>>>>>>> local-version
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF40C4FF), Color(0xFF80D8FF)], // Gradient colors
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        items: [
          // Native sailing icon
          const BottomNavigationBarItem(
            icon: Icon(Icons.sailing), // Use the sailing icon
            label: 'Home',
          ),
          const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Daily Activities'),
          // Custom treasure chest icon
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/icons/treasure.png', // Custom treasure chest icon
              width: 30,
              height: 30,
            ),
            label: 'Achievements',
          ),
          // Settings icon remains as-is
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        iconSize: 30,
=======
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF1C2C5B), Color(0xFF3949AB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: selectedIndex,
              onTap: onItemTapped,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white60,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              iconSize: 22,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.sailing),
                  label: 'Home',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Daily',
                ),
                BottomNavigationBarItem(
                  icon: Image.asset(
                    'assets/icons/treasure.png',
                    width: 22,
                    height: 22,
                  ),
                  label: 'Achievements',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
>>>>>>> local-version
      ),
    );
  }
}
<<<<<<< HEAD
=======










>>>>>>> local-version
