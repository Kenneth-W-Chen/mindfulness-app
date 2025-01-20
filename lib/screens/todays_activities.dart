import '../custom_bottom_navigation_bar.dart';
import 'activities/calmingcliffintro.dart';
import 'shared/activity_widget.dart';
import 'package:flutter/material.dart';
import '../storage.dart';
import 'activities/meditation_station.dart';
import 'activities/twilight_alley_intro.dart';
import 'package:calm_quest/breathing_activity.dart';
import 'package:calm_quest/screens/activities/Mood%20Journal/mood_selection_screen.dart';

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
    ActivityName.breathe: BreathingActivity.new,
    ActivityName.calming_cliffs: CalmingCliffsIntro.new,
    ActivityName.mood_journal: MoodSelectionScreen.new
  };

  static const Map<ActivityName, IconData> activityNameIcons = const {
    ActivityName.meditation_station: Icons.headset,
    ActivityName.twilight_alley: Icons.flag,
    ActivityName.breathe: Icons.phone_in_talk,
    ActivityName.calming_cliffs: Icons.landscape,
    ActivityName.mood_journal: Icons.book
  };

  static const Map<ActivityName, String> activityNameDescription = const {
    ActivityName.meditation_station:
        'Listen to calming sounds and nature noises.',
    ActivityName.twilight_alley: 'Journal some of your thoughts',
    ActivityName.breathe: 'Take a moment to recollect yourself',
    ActivityName.calming_cliffs: 'Calm yourself and realize that there is so much out there.',
    ActivityName.mood_journal: 'Talk about how you feel today',
  };

  List<Map<String, Object>> activities = [];

  _TodaysActivitiesScreenState();

  @override
  void initState() {
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
