import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../storage.dart';

class UserStats extends StatefulWidget {
  Storage storage;

  UserStats({super.key, required this.storage});

  @override
  State<StatefulWidget> createState() => _UserStatsState();
}

class _UserStatsState extends State<UserStats> {
  int theme = 0;

  final Color _cardColorLight = Colors.white;
  final Color _cardColorDark = Colors.black12; // may consider swapping with black38?
  final TextStyle _fontColorLight = const TextStyle(color:Colors.black);
  final TextStyle _fontColorDark = const TextStyle(color:Colors.white);

  String achiementsCompleted = "0";
  String dailiesCompleted = "0";
  String favoriteActivity = "Meditation Station";

  @override
  void initState() {
    super.initState();
    asyncInitState();
  }

  Future<void> asyncInitState() async {
    theme = (await widget.storage.getPreferences([PreferenceName.theme]))![PreferenceName.theme] as int;
    achiementsCompleted = '${await widget.storage.achievementCount()}';
    dailiesCompleted = '${await widget.storage.getDailyActivityCompletionCount()}';
    var activityLogCounts = await widget.storage.getActivityLogCount();
    favoriteActivity = ActivityName.values[activityLogCounts[0]['activity_id'] as int].toString();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme == 1 ? Colors.grey[500] : Colors.lightBlue[500],
      appBar: AppBar(
        title: Text('Stats',style: _getTextStyle(),),
        centerTitle: true,
        backgroundColor: theme == 1 ? Colors.grey[900] : Colors.lightBlue[700]
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Stat: Total days since first app open
          Card(
            color: theme == 1 ? _cardColorDark : _cardColorLight,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                    image: AssetImage(theme == 1 ? 'assets/images/user_stats_1_dark.png':'assets/images/user_stats_1_light.png'),
                    fit: BoxFit.fitWidth,
                  ),
                Container(
                  padding: const EdgeInsets.all(2.0),
                  constraints: const BoxConstraints(minHeight: 50.0),
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Text(
                      "You've been on your quest for ? days.",
                      style: _getTextStyle(),
                  ),
                )
              ],
            )
          ),
          // Second row of stats
          Row(
            children:[
              // Stat: Number of achievements completed
              Expanded(
                child: Card(
                  color: theme == 1 ? _cardColorDark : _cardColorLight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Image(image: AssetImage('assets/icons/trophy.png'), width: 150,),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 40.0),
                              child: Text(
                                achiementsCompleted,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('Achievements Completed', style: _getTextStyle()),
                      )
                    ],
                  ),
                )
              ),
              // Stat: Favorite Activity todo
              Expanded(
                  child: Card(
                    color: theme == 1 ? _cardColorDark : _cardColorLight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            const Image(image: AssetImage('assets/icons/trophy.png'), width: 150,),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 40.0),
                                child: Text(
                                  achiementsCompleted,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                )
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text('Achievements Completed', style: _getTextStyle()),
                        )
                      ],
                    ),
                  )
              ),
            ]
          ),
          // Third row of stats
          Row(
            children: [
              // Stat: Times all daily activities have been completed
              Expanded(
                child: Card(
                  color: theme == 1 ? _cardColorDark : _cardColorLight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("You've completed your", textAlign: TextAlign.center, style: _getTextStyle()),
                      ),
                      Stack(
                          alignment: Alignment.center,
                          children: [
                            const Image(
                              image: AssetImage('assets/icons/calendar.png'),
                              width: 150,
                            ),
                            Container(
                                alignment: Alignment.center,
                                width: 150,
                                height: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,

                                  children: [
                                    const Expanded(
                                        flex: 2,
                                        child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 7),
                                            child: Text(
                                              "Dailies",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.white
                                              ),
                                            )
                                        )
                                    ),
                                    Expanded(
                                        flex: 8,
                                        child: Align(
                                            child: Text(
                                              dailiesCompleted,
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            )
                                        ),
                                    )
                                  ],
                                )
                            )
                          ],
                        ),
                        Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('times', style: _getTextStyle()),
                      )
                    ],
                  ),
                ),
              ),
              // Stat: Longest daily activity completion streak todo
              Expanded(
                child: Card(
                  color: theme == 1 ? _cardColorDark : _cardColorLight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("You've completed your daily activities", textAlign: TextAlign.center, style: _getTextStyle()),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Image(image: AssetImage('assets/icons/trophy.png'), width: 150,),
                          Padding(
                              padding: const EdgeInsets.only(bottom: 40.0),
                              child: Text(
                                achiementsCompleted,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('times', style: _getTextStyle()),
                      )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      )
    );
  }

  TextStyle _getTextStyle() => theme == 1 ? _fontColorDark : _fontColorLight;
}
