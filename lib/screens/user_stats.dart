import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import '../storage.dart';

class UserStats extends StatefulWidget {

  const UserStats({super.key});

  @override
  State<StatefulWidget> createState() => _UserStatsState();
}

class _UserStatsState extends State<UserStats>  with TickerProviderStateMixin {
  int theme = 0;

  final Color _cardColorLight = Colors.white;
  final Color _cardColorDark = Colors.black12; // may consider swapping with black38?
  final TextStyle _fontColorLight = const TextStyle(color:Colors.black);
  final TextStyle _fontColorDark = const TextStyle(color:Colors.white);

  String achievementsCompleted = "0";
  String dailiesCompleted = "0";
  bool hasActivityLogs = true;
  String favoriteActivity = "";
  String favoriteActivitySubtext = "Keep playing to find your favorite activity.";
  String favoriteActivityCount = "?";
  String longestStreak = "0";

  late AnimationController _animationController;
  late Animation<double> _growAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(seconds: 5), vsync: this)..repeat(reverse: true);
    _growAnimation = Tween<double>(begin: .2, end: .45).animate(_animationController);
    asyncInitState();
  }

  @override
  void dispose(){
    _animationController.dispose();

    super.dispose();
  }

  Future<void> asyncInitState() async {
    theme = (await Storage.storage.getPreferences([PreferenceName.theme]))![PreferenceName.theme] as int;
    // doing a setState here since fetching the other data can take a while
    setState(() {

    });
    achievementsCompleted = '${await Storage.storage.achievementCount()}';
    dailiesCompleted = '${await Storage.storage.getDailyActivityCompletionCount()}';
    longestStreak = '${await Storage.storage.getLongestDailyCompletionStreak()}';
    var activityLogCounts = await Storage.storage.getActivityLogCount();
    hasActivityLogs = activityLogCounts.isNotEmpty;
    if(hasActivityLogs) {
      var activityLogCount = activityLogCounts[0]['cnt'] as int;
      hasActivityLogs = activityLogCount > 0;
      if (hasActivityLogs) {

        favoriteActivity =
            "Your favorite activity is ${ActivityName.values[activityLogCounts[0]['activity_id'] as int].toString()}.";
        favoriteActivitySubtext = "You've completed it $activityLogCount time";
        if (activityLogCount > 1) {
          favoriteActivitySubtext += 's';
        }
        favoriteActivitySubtext += '.';
        favoriteActivityCount = activityLogCount.toString();
      }
    }
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
            color: _getCardColor(),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gif(
                  image: AssetImage(
                      theme == 1 ? 'assets/images/user_stats_1_dark.gif' : 'assets/images/user_stats_1_light.gif'
                  ),
                  autostart: Autostart.loop,
                  placeholder: (BuildContext c){
                    return Image.asset(
                      theme == 1 ? 'assets/images/user_stats_1_dark.png' : 'assets/images/user_stats_1_light.png'
                    );
                  }
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
                      color: _getCardColor(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('\n${hasActivityLogs? '\n' : ''}'), // added to force card heights to match... intrinsic height increases the height by 20 pixels
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Image(image: AssetImage('assets/icons/trophy.png'), width: 150,),
                              Padding(
                                  padding: const EdgeInsets.only(bottom:40.0),
                                  child: Text(
                                    achievementsCompleted,
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
                // Stat: Favorite Activity
                Expanded(
                    child: Card(
                      color: _getCardColor(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(favoriteActivity, style: _getTextStyle(), textAlign: TextAlign.center,),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              const Image(image: AssetImage('assets/icons/meditate.png'), width: 150,),
                              AnimatedBuilder(
                                  animation: _growAnimation,
                                  builder: (context,child){
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          radius: 1,
                                          stops: [.1,_growAnimation.value,.9],
                                          colors: const [Color(0xCC3B59DB), Color(0xAA508BC7), Color(0x3300D8FF)],
                                        ),
                                      ),
                                    );
                                  }
                              ),
                              Text(
                                favoriteActivityCount,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white
                                ),
                              )
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              favoriteActivitySubtext,
                              style: _getTextStyle(),
                              textAlign: TextAlign.center,
                            ),

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
                  color: _getCardColor(),
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
                        child: Text(int.parse(dailiesCompleted) == 1 ? 'time.':'times.', style: _getTextStyle()),
                      )
                    ],
                  ),
                ),
              ),
              // Stat: Longest daily activity completion streak
              Expanded(
                child: Card(
                  color: _getCardColor(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text("Longest daily activity streak", textAlign: TextAlign.center, style: _getTextStyle()),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          const Image(image: AssetImage('assets/icons/flame.png'), width: 150,),
                          Padding(
                              padding: const EdgeInsets.only(top: 65.0),
                              child: Text(
                                longestStreak,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              )
                          )
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(14.0),
                        child: const Text('\r'),
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

  Color _getCardColor() => theme == 1 ? _cardColorDark : _cardColorLight;

  TextStyle _getTextStyle() => theme == 1 ? _fontColorDark : _fontColorLight;
}
