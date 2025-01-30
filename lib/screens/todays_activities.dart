import 'package:calm_quest/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../custom_bottom_navigation_bar.dart';
import 'shared/activity_widget.dart';
import 'package:flutter/material.dart';
import '../storage.dart';
import 'activities/meditation_station.dart';
import 'activities/twilight_alley_intro.dart';
import 'package:calm_quest/breathing_activity.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest_all.dart';
import 'package:flutter_timezone/flutter_timezone.dart';


class TodaysActivitiesScreen extends StatefulWidget {
  const TodaysActivitiesScreen({super.key});

  @override
  State<TodaysActivitiesScreen> createState() => _TodaysActivitiesScreenState();
}

class _TodaysActivitiesScreenState extends State<TodaysActivitiesScreen> {
  late Storage storage;

  static const Map<ActivityName, StatefulWidget Function()>
      activityNameToFunction = const {
    ActivityName.meditation_station: MeditationStation.new,
    ActivityName.twilight_alley: TwilightAlleyIntro.new,
    ActivityName.breathe: BreathingActivity.new
  };

  static const Map<ActivityName, IconData> activityNameIcons = const {
    ActivityName.meditation_station: Icons.headset,
    ActivityName.twilight_alley: Icons.flag,
    ActivityName.breathe: Icons.phone_in_talk
  };

  static const Map<ActivityName, String> activityNameDescription = const {
    ActivityName.meditation_station:
        'Listen to calming sounds and nature noises.',
    ActivityName.twilight_alley: 'Journal some of your thoughts',
    ActivityName.breathe: 'Take a moment to recollect yourself'
  };

  List<Map<String, Object>> activities = [];

  _TodaysActivitiesScreenState();

  @override
  void initState() {
    // if the program is being debugged, schedules a notification to occur 30 seconds from now daily (e.g., always at 10:00:30 everyday)
    if(kDebugMode){
      print('Adding notification');
      notifications.schedule(NotificationIds.debugNotification.value, 'New daily activities are ready', 'New daily activities are ready.', TZDateTime.now(notifications.timezone).add(const Duration(seconds: 30)), matchDateTimeComponents: DateTimeComponents.time);
    } else{ // schedules a notification to occur every day at 10am
      TZDateTime tomorrow = TZDateTime.now(notifications.timezone).add(const Duration(days:1));
      notifications.schedule(NotificationIds.dailyReset.value, 'New daily activities are ready', 'New daily activities are ready.', TZDateTime.local(tomorrow.year,tomorrow.month,tomorrow.day,10), matchDateTimeComponents: DateTimeComponents.time);
    }
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit() async {
    storage = await Storage.create();
    activities = await storage.dailyReset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Today's Activities",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.amber[800],
        elevation: 0,
      ),
      body: Container(
        color: Colors.amber[700],
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Here are the activities for today!",
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 30),
              ...(List<Widget>.generate(activities.length, (int index) {
                var activity = activities[index];
                return activityCard(
                    activity['activity'].toString(),
                    context,
                    (activity['completed'] as bool)
                        ? Icons.check
                        : activityNameIcons[activity['activity']]!,
                    activityNameDescription[activity['activity']]! +
                        ((activity['completed'] as bool)
                            ? '\nYou already completed this activity today.'
                            : ''),
                    builder: (context) =>
                        activityNameToFunction[activity['activity']]!(),
                    cardColor: (activity['completed'] as bool)
                        ? Colors.grey.withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    shadowColor: Colors.black.withOpacity(0.3),
                    iconBackgroundColor: Colors.amber[700],
                    iconColor: Colors.white,
                    textColor: Colors.amber[900],
                    subTextColor: Colors.amber[800],
                    onPop: (value) {
                      storage.setDailyCompleted(index + 1);
                      activities[index]['completed'] = value as bool;
                      debugPrint("Set activity $index completion to ${value as bool?'true':'false'}");
                      setState(() {});
                    });
              }))
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 1,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/'); // Navigate to Home
          } else if(index == 2){
            Navigator.pushReplacementNamed(context, '/achievements');
          }
          else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/settings'); // Navigate to Settings
          }
        },
      ),
    );
  }
}
