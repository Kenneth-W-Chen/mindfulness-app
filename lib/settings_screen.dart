import 'package:flutter/material.dart';
import 'Custom_Bottom_Navigation_Bar.dart';
import 'storage.dart';
import 'placeholder_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late Storage storage;
  Map<PreferenceName, int> preferences = {};
  ThemeMode _themeMode = ThemeMode.dark;
  bool _notificationsEnabled = false;
  bool _backgroundMusicEnabled = false;
  bool _soundEffectsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      storage = await Storage.create();
      Map<PreferenceName, int> loadedPreferences =
          await storage.getPreferences([
        PreferenceName.master_volume,
        PreferenceName.music_volume,
        PreferenceName.sound_fx_volume
      ]) ?? {};

      setState(() {
        preferences = loadedPreferences;
        _notificationsEnabled = (preferences[PreferenceName.master_volume] ?? 0) > 50;
        _backgroundMusicEnabled = (preferences[PreferenceName.music_volume] ?? 0) > 50;
        _soundEffectsEnabled = (preferences[PreferenceName.sound_fx_volume] ?? 0) > 50;
      });
    } catch (e) {
      setState(() {
        preferences = {};
      });
    }
  }

  void _updatePreferences(PreferenceName preference, int value) {
    storage.updatePreferences({preference: value});
    setState(() {
      preferences[preference] = value;
    });
  }

  void _toggleTheme(String? theme) {
    setState(() {
      _themeMode = (theme == 'Light') ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (context) {
        String oldPassword = '';
        String newPassword = '';
        String confirmPassword = '';
        return AlertDialog(
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Old Password'),
                onChanged: (value) => oldPassword = value,
              ),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                onChanged: (value) => newPassword = value,
              ),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                onChanged: (value) => confirmPassword = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPassword == confirmPassword && newPassword.isNotEmpty) {
                  // Implement password change logic
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password changed successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match!')),
                  );
                }
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          centerTitle: true,
        ),
        body: preferences.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Change Avatar'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlaceholderScreen(
                          message: 'Change Avatar - Feature in Progress',
                        ),
                      ),
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Enable Notifications'),
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                        _updatePreferences(PreferenceName.master_volume, value ? 100 : 0);
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Theme'),
                    trailing: DropdownButton<String>(
                      value: _themeMode == ThemeMode.light ? 'Light' : 'Dark',
                      items: const [
                        DropdownMenuItem(value: 'Light', child: Text('Light')),
                        DropdownMenuItem(value: 'Dark', child: Text('Dark')),
                      ],
                      onChanged: _toggleTheme,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Background Music'),
                    value: _backgroundMusicEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _backgroundMusicEnabled = value;
                        _updatePreferences(PreferenceName.music_volume, value ? 100 : 0);
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Sound Effects'),
                    value: _soundEffectsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _soundEffectsEnabled = value;
                        _updatePreferences(PreferenceName.sound_fx_volume, value ? 100 : 0);
                      });
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: _changePassword,
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete Account'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlaceholderScreen(
                          message: 'Delete Account - Feature in Progress',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: 2,
          onItemTapped: (index) {
            if (index == 0) {
              Navigator.pushReplacementNamed(context, '/');
            } else if (index == 1) {
              Navigator.pushReplacementNamed(context, '/achievements');
            }
          },
        ),
      ),
    );
  }
}