import 'package:flutter/material.dart';
import 'custom_bottom_navigation_bar.dart';
import 'storage.dart';
import 'placeholder_screen.dart'; // Import placeholder screen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Storage storage;
  Map<PreferenceName, int>? preferences;
  String _selectedTheme = 'Dark'; // Default theme is Dark

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      storage = await Storage.create();
      preferences = await storage.getPreferences([PreferenceName.all]);
      setState(() {});
    } catch (e) {
      setState(() {
        preferences = {};
      });
    }
  }

  void _updatePreferences(PreferenceName preference, int value) {
    storage.updatePreferences({preference: value});
    setState(() {
      preferences![preference] = value;
    });
  }

  void _toggleTheme(String? theme) {
    if (theme == 'Light') {
      _selectedTheme = 'Light';
      // Switch to light theme
      setState(() {
        // Implement light theme logic here
      });
    } else {
      _selectedTheme = 'Dark';
      // Switch to dark theme
      setState(() {
        // Implement dark theme logic here
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: preferences == null
          ? const Center(child: CircularProgressIndicator())
          : preferences!.isEmpty
              ? const Center(child: Text('No preferences available'))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const Text(
                      'Account Settings',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Change Avatar'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlaceholderScreen(message: 'Change Avatar - Feature in Progress'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    const Text(
                      'App Preferences',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      value: (preferences?[PreferenceName.master_volume] ?? 0) > 50, 
                      onChanged: (bool value) {
                        _updatePreferences(PreferenceName.master_volume, value ? 100 : 0);
                      },
                    ),
                    
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme'),
                      trailing: DropdownButton<String>(
                        value: _selectedTheme,
                        items: const [
                          DropdownMenuItem(value: 'Light', child: Text('Light')),
                          DropdownMenuItem(value: 'Dark', child: Text('Dark')),
                        ],
                        onChanged: _toggleTheme,
                      ),
                    ),
                    
                    const Divider(),
                    const SizedBox(height: 10),

                    const Text(
                      'Sound & Music',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    
                    SwitchListTile(
                      title: const Text('Background Music'),
                      value: (preferences?[PreferenceName.music_volume] ?? 0) > 50, 
                      onChanged: (bool value) {
                        _updatePreferences(PreferenceName.music_volume, value ? 100 : 0);
                      },
                    ),
                    
                    SwitchListTile(
                      title: const Text('Sound Effects'),
                      value: (preferences?[PreferenceName.sound_fx_volume] ?? 0) > 50, 
                      onChanged: (bool value) {
                        _updatePreferences(PreferenceName.sound_fx_volume, value ? 100 : 0);
                      },
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    const Text(
                      'Privacy & Security',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListTile(
                      leading: const Icon(Icons.lock),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlaceholderScreen(message: 'Change Password - Feature in Progress'),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.delete),
                      title: const Text('Delete Account'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PlaceholderScreen(message: 'Delete Account - Feature in Progress'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 3, // Ensure Settings is selected
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/'); // Navigate to Home
          } else if (index == 1){
            Navigator.pushReplacementNamed(context, '/todays_activities');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/achievements'); // Navigate to Achievements
          }
        },
      ),
    );
  }
}