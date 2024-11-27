import 'shared/activity_widget.dart';
import 'package:flutter/material.dart';
import '../storage.dart';
import 'activities/meditation_station.dart';
import 'activities/twilight_alley_intro.dart';

class TodaysActivitiesScreen extends StatefulWidget{
  const TodaysActivitiesScreen({super.key});
  @override
  State<TodaysActivitiesScreen> createState() => _TodaysActivitiesScreenState();
}

class _TodaysActivitiesScreenState extends State<TodaysActivitiesScreen>{
  late Storage storage;

  static const Map<ActivityName, StatefulWidget Function()> activityNameToFunction = const{
    ActivityName.meditation_station:
    MeditationStation.new,
    ActivityName.twilight_alley: TwilightAlleyIntro.new,
    ActivityName.breathe: MeditationStation.new
  };

  static const Map<ActivityName, IconData> activityNameIcons = const{
    ActivityName.meditation_station: Icons.headset,
    ActivityName.twilight_alley: Icons.flag,
    ActivityName.breathe: Icons.phone_in_talk
  };

  static const Map<ActivityName, String> activityNameDescription = const{
    ActivityName.meditation_station: 'Listen to calming sounds and nature noises.',
    ActivityName.twilight_alley:                   'Journal some of your thoughts',
    ActivityName.breathe: 'This activity is a work in progress!'
  };

  List<ActivityName> activities = [];


  _TodaysActivitiesScreenState();

  @override
  void initState(){
    super.initState();
    asyncInit();
  }

  Future<void> asyncInit() async{
    storage = await Storage.create();
    activities = await storage.dailyReset();
    setState((){});
  }

  @override
  Widget build(BuildContext context){
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
              ...(activities.map(
                      (activityName)=>
                          activityCard(activityName.toString(), context, activityNameIcons[activityName]!, activityNameDescription[activityName]!, builder: (context)=> activityNameToFunction[activityName]!(), cardColor: Colors.white.withOpacity(0.9), shadowColor: Colors.black.withOpacity(0.3), iconBackgroundColor: Colors.amber[700], iconColor: Colors.white, textColor: Colors.amber[900], subTextColor: Colors.amber[800]             )))
            ],
          ),
        ),
      ),
    );
  }
}