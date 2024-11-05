import 'package:flutter/material.dart';
import '../mockhome_screen.dart'; // Correct import for navigation back to home
import '../../storage.dart'; // Import the Storage class

class MockSettings extends StatefulWidget {
  const MockSettings({Key? key}) : super(key: key);

  @override
  _MockSettingsState createState() => _MockSettingsState();
}

class _MockSettingsState extends State<MockSettings> {
  late Storage _storage;
  String _preferenceDisplay = 'Loading preferences...';

  @override
  void initState() {
    super.initState();
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    _storage = await Storage.create();
    await _fetchPreferences();
  }

  Future<void> _fetchPreferences() async {
    // Fetching preferences for display (you can modify which preferences to display)
    Map<PreferenceName, int>? preferences = await _storage.getPreferences([PreferenceName.master_volume, PreferenceName.music_volume]);

    setState(() {
      if (preferences != null && preferences.isNotEmpty) {
        _preferenceDisplay = preferences.entries
            .map((entry) => '${entry.key.name}: ${entry.value}')
            .join('\n');
      } else {
        _preferenceDisplay = 'No preferences found.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.settings,
                size: 80,
                color: Colors.white,
              ),
              const SizedBox(height: 20),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Customize your CalmQuest experience!',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 30),
              // Displaying the fetched preferences
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _preferenceDisplay,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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
        currentIndex: 2, // Highlight the settings icon
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MockHomeScreen()),
            );
          }
        },
      ),
    );
  }
}
