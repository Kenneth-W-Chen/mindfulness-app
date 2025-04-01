import 'package:calm_quest/notifications.dart';
import 'package:calm_quest/screens/activities/mellowmazeintro.dart';
import 'package:calm_quest/screens/activities/pos_affirm_activity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../custom_bottom_navigation_bar.dart';
import 'activities/calmingcliffintro.dart';
import 'shared/activity_widget.dart';
import 'package:flutter/material.dart';
import '../storage.dart';
import 'activities/meditation_station.dart';
import 'activities/twilight_alley_intro.dart';
import 'package:calm_quest/breathing_activity.dart';
import 'package:calm_quest/screens/activities/Mood%20Journal/mood_selection_screen.dart';
import 'package:timezone/timezone.dart';

class TodaysActivitiesScreen extends StatefulWidget {
  const TodaysActivitiesScreen({super.key});

  @override
  State<TodaysActivitiesScreen> createState() => _TodaysActivitiesScreenState();
}

class _TodaysActivitiesScreenState extends State<TodaysActivitiesScreen> {
  late Storage storage;

  static const Map<ActivityName, StatefulWidget Function()>
      activityNameToFunction = {
    ActivityName.meditation_station: MeditationStation.new,
    ActivityName.twilight_alley: TwilightAlleyIntro.new,
    ActivityName.breathe: BreathingActivity.new,
    ActivityName.calming_cliffs: CalmingCliffsIntro.new,
    ActivityName.mood_journal: MoodSelectionScreen.new,
    ActivityName.mellow_maze: MellowMazeIntro.new,
    ActivityName.positive_affirmations: QuoteScreen.new,
  };

  static const Map<ActivityName, IconData> activityNameIcons = {
    ActivityName.meditation_station: Icons.headset,
    ActivityName.twilight_alley: Icons.flag,
    ActivityName.breathe: Icons.phone_in_talk,
    ActivityName.calming_cliffs: Icons.landscape,
    ActivityName.mood_journal: Icons.book,
    ActivityName.mellow_maze: Icons.blur_circular,
    ActivityName.positive_affirmations: Icons.book,
  };

  static const Map<ActivityName, String> activityNameDescription = {
    ActivityName.meditation_station:
        'Listen to calming sounds and nature noises.',
    ActivityName.twilight_alley: 'Journal some of your thoughts',
    ActivityName.breathe: 'Take a moment to recollect yourself',
    ActivityName.calming_cliffs:
        'Calm yourself and realize that there is so much out there.',
    ActivityName.mood_journal: 'Talk about how you feel today',
    ActivityName.mellow_maze: "Traverse the maze to clear your mind.",
    ActivityName.positive_affirmations: "Ground yourself with positive affirmations",
  };

  List<bool> dayCompletedList = List<bool>.filled(7, false);

  List<Map<String, Object>> activities = [];
  late int todayWeekday;

  _TodaysActivitiesScreenState();

  @override
  void initState() {
    super.initState();
    todayWeekday = DateTime.now().weekday;
    if (todayWeekday == 7) todayWeekday = 0;

    asyncInit();
  }

  Future<void> asyncInit() async {
    storage = await Storage.create();

    // Set up daily activities
    activities = await storage.dailyReset();

    // set up completion indicator
    List<Map<String, Object>?> completionInfo = await storage.getDailyResetInfo(
        startDate: DateTime.now().subtract(Duration(days: todayWeekday)));

    for (int i = 0; i < completionInfo.length; i++) {
      if (completionInfo[i] == null ||
          !completionInfo[i]!.containsKey('activity_completed')) continue;
      int dayCompletedIndex = (completionInfo[i]!['date']! as DateTime).weekday;
      if (dayCompletedIndex == 7) dayCompletedIndex = 0;
      dayCompletedList[dayCompletedIndex] =
          ((completionInfo[i]!['activity_completed'] as int) & 7) == 7;
    }

    setState(() {});
    // Set up notifications
    // Don't schedule notifs if notifs are disabled
    if((await storage.getPreferences([PreferenceName.notifs]))![PreferenceName.notifs] as int == 0) return;
    // if the program is being debugged, schedules a notification to occur 30 seconds from now daily (e.g., always at 10:00:30 everyday)
    if (kDebugMode) {
      print('Adding notification');
      notifications.schedule(
          NotificationIds.debugNotification.value,
          'New daily activities are ready',
          'New daily activities are ready.',
          TZDateTime.now(notifications.timezone)
              .add(const Duration(seconds: 3)),
          matchDateTimeComponents: DateTimeComponents.time);
    } else {
      // schedule a notification to occur every day at 10am
      // don't reschedule it if it's already been scheduled
      if (!await notifications.isScheduled(NotificationIds.dailyReset)) return;
      TZDateTime tomorrow =
          TZDateTime.now(notifications.timezone).add(const Duration(days: 1));
      notifications.schedule(
          NotificationIds.dailyReset.value,
          'New daily activities are ready',
          'New daily activities are ready.',
          TZDateTime.local(tomorrow.year, tomorrow.month, tomorrow.day, 10),
          matchDateTimeComponents: DateTimeComponents.time);
    }
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
              Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  completionCard(dayCompletedList[0], 'Su'),
                  completionCard(dayCompletedList[1], 'Mo'),
                  completionCard(dayCompletedList[2], 'Tu'),
                  completionCard(dayCompletedList[3], 'We'),
                  completionCard(dayCompletedList[4], 'Th'),
                  completionCard(dayCompletedList[5], 'Fr'),
                  completionCard(dayCompletedList[6], 'Sa'),
                ],
              )),
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
                      if (value as bool) {
                        storage.setDailyCompleted(index + 1);
                        activities[index]['completed'] = value;
                      }
                      debugPrint(
                          "Set activity $index completion to ${value ? 'true' : 'false'}");
                      if (activities.every((e) => e['completed'] == true))
                        dayCompletedList[todayWeekday] = true;
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
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/achievements');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(
                context, '/settings'); // Navigate to Settings
          }
        },
      ),
    );
  }

  Card completionCard(bool completed, String day) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              children: [
                Icon(completed
                    ? Icons.check_box_outlined
                    : Icons.square_outlined),
                Text(day)
              ],
            )));
  }
}
