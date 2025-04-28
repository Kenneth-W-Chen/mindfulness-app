<<<<<<< HEAD
import 'package:calm_quest/notifications.dart';
import 'package:calm_quest/screens/user_stats.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart';
import 'Custom_Bottom_Navigation_Bar.dart';
import 'storage.dart';
import 'placeholder_screen.dart'; // Import placeholder screen
=======
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calm_quest/theme_notifier.dart';
import 'package:calm_quest/notifications.dart';
import 'package:calm_quest/screens/user_stats.dart';
import 'package:calm_quest/storage.dart';
import 'package:calm_quest/placeholder_screen.dart';
import 'package:calm_quest/Custom_Bottom_Navigation_Bar.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

>>>>>>> local-version

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
<<<<<<< HEAD
  _SettingsScreenState createState() => _SettingsScreenState();
=======
  State<SettingsScreen> createState() => _SettingsScreenState();
>>>>>>> local-version
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<PreferenceName, int>? preferences;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
<<<<<<< HEAD
    try {
      preferences = await Storage.storage.getPreferences([PreferenceName.all]);
      setState(() {});
    } catch (e) {
      setState(() {
        preferences = {};
      });
    }
  }

  void _updatePreferences(PreferenceName preference, int value) {
    Storage.storage.updatePreferences({preference: value});
    setState(() {
      preferences![preference] = value;
    });
  }

  void _toggleTheme(Themes? theme) {
    _updatePreferences(PreferenceName.theme, theme!.index);
    switch(theme){
      case Themes.light:
      // Implement light theme logic here
        break;
      case Themes.dark:
      // Implement dark theme logic here
        break;
      default:
        break;
    }
  }
  
  Future<void> _rescheduleNotifications() async {
    if(!await notifications.isScheduled(NotificationIds.dailyReset)) return;
    TZDateTime tomorrow = TZDateTime.now(notifications.timezone).add(const Duration(days:1));
    notifications.schedule(NotificationIds.dailyReset.value, 'New daily activities are ready', 'New daily activities are ready.', TZDateTime.local(tomorrow.year,tomorrow.month,tomorrow.day,10), matchDateTimeComponents: DateTimeComponents.time);
=======
    preferences = await Storage.storage.getPreferences([PreferenceName.all]);
    setState(() {});
  }

  void _updatePreferences(PreferenceName pref, int value) {
    Storage.storage.updatePreferences({pref: value});
    setState(() {
      preferences![pref] = value;
    });
  }

  Future<void> _rescheduleNotifications() async {
    if (!await notifications.isScheduled(NotificationIds.dailyReset)) return;
    final tomorrow = tz.TZDateTime.now(tz.local).add(const Duration(days: 1));
    await notifications.schedule(
      NotificationIds.dailyReset.value,
      'New daily activities are ready',
      'New daily activities are ready.',
      tz.TZDateTime(tz.local, tomorrow.year, tomorrow.month, tomorrow.day, 10),
      matchDateTimeComponents: DateTimeComponents.time,
    );
>>>>>>> local-version
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
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
                    ListTile(
                      leading: const Icon(Icons.bar_chart),
                      title: const Text('Usage Statistics'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UserStats(),
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
                      value: (preferences?[PreferenceName.notifs] as int) == 1,
                      onChanged: (bool value) async {
                        _updatePreferences(PreferenceName.notifs, value ? 1 : 0);
                        if(value){
                         await _rescheduleNotifications();
                        }
                        else {
                          await notifications.plugin.cancelAll();
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme'),
                      trailing: DropdownButton<Themes>(
                        value: Themes.values[preferences![PreferenceName.theme]!],
                        items: const [
                          DropdownMenuItem(value: Themes.light, child: Text('Light')),
                          DropdownMenuItem(value: Themes.dark, child: Text('Dark')),
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
                    ListTile(
                        leading: const Icon(Icons.volume_up),
                        title: const Text('Master Volume'),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 80,
                                child: Slider(
                                  value: (preferences?[PreferenceName.master_volume] as int).toDouble(),
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double val){
                                    _updatePreferences(PreferenceName.master_volume, val.round());
                                  },
                                )
                            ),
                            Expanded(
                                flex: 20,
                                child: Text(
                                    (preferences?[PreferenceName.master_volume] as int).toString(),
                                    textAlign: TextAlign.right
                                )
                            )
                          ],
                        )
                    ),
                    ListTile(
                      leading: const Icon(Icons.music_note),
                      title: const Text('Background Music'),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 80,
                            child: Slider(
                              value: (preferences?[PreferenceName.music_volume] as int).toDouble(),
                              max: 10,
                              divisions: 10,
                              onChanged: (double val){
                                _updatePreferences(PreferenceName.music_volume, val.round());
                              },
                            )
                          ),
                          Expanded(
                              flex: 20,
                              child: Text(
                                (preferences?[PreferenceName.music_volume] as int).toString(),
                                textAlign: TextAlign.right
                              )
                          )
                        ],
                      )
                    ),
                    ListTile(
                        leading: const Icon(Icons.graphic_eq),
                        title: const Text('Sound Effects'),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                                flex: 80,
                                child: Slider(
                                  value: (preferences?[PreferenceName.sound_fx_volume] as int).toDouble(),
                                  max: 10,
                                  divisions: 10,
                                  onChanged: (double val){
                                    _updatePreferences(PreferenceName.sound_fx_volume, val.round());
                                  },
                                )
                            ),
                            Expanded(
                                flex: 20,
                                child: Text(
                                    (preferences?[PreferenceName.sound_fx_volume] as int).toString(),
                                    textAlign: TextAlign.right
                                )
                            )
                          ],
                        )
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

enum Themes{
  light,
  dark;
}
=======
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Color(0xFF141E30), Color(0xFF1A237E)]
              : [Color(0xFFE0F7FA), Color(0xFFB2EBF2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Settings"),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: preferences == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const Text("App Preferences", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  SwitchListTile(
                    title: const Text('Dark Theme', style: TextStyle(color: Colors.white)),
                    value: isDark,
                    onChanged: (value) {
                      themeNotifier.setTheme(value ? ThemeMode.dark : ThemeMode.light);
                      _updatePreferences(PreferenceName.theme, value ? Themes.dark.index : Themes.light.index);
                    },
                  ),
                  SwitchListTile(
                    title: const Text("Enable Notifications", style: TextStyle(color: Colors.white)),
                    value: preferences?[PreferenceName.notifs] == 1,
                    onChanged: (value) async {
                      _updatePreferences(PreferenceName.notifs, value ? 1 : 0);
                      value
                          ? await _rescheduleNotifications()
                          : await notifications.plugin.cancelAll();
                    },
                  ),
                  const Divider(color: Colors.white),
                  const Text("Sound & Music", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  _buildSliderTile("Master Volume", PreferenceName.master_volume),
                  _buildSliderTile("Music Volume", PreferenceName.music_volume),
                  _buildSliderTile("Sound FX Volume", PreferenceName.sound_fx_volume),
                  const Divider(color: Colors.white),
                  const Text("Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ListTile(
                    leading: const Icon(Icons.bar_chart, color: Colors.white),
                    title: const Text("Usage Stats", style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserStats())),
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.white),
                    title: const Text("Change Password", style: TextStyle(color: Colors.white)),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PlaceholderScreen(message: "Coming soon!"))),
                  ),
                ],
              ),
        bottomNavigationBar: CustomBottomNavigationBar(
          selectedIndex: 3,
          onItemTapped: (index) {
            if (index == 0) Navigator.pushReplacementNamed(context, '/');
            else if (index == 1) Navigator.pushReplacementNamed(context, '/todays_activities');
            else if (index == 2) Navigator.pushReplacementNamed(context, '/achievements');
          },
        ),
      ),
    );
  }

  Widget _buildSliderTile(String label, PreferenceName prefName) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      subtitle: Slider(
        value: (preferences?[prefName] ?? 5).toDouble(),
        max: 10,
        divisions: 10,
        onChanged: (val) => _updatePreferences(prefName, val.round()),
      ),
      trailing: Text((preferences?[prefName] ?? 5).toString(), style: const TextStyle(color: Colors.white)),
    );
  }
}

enum Themes {
  light,
  dark,
}



>>>>>>> local-version
