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
      ),
    );
  }
}










