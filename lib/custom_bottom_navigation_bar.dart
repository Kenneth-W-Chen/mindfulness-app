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
      ),
    );
  }
}
