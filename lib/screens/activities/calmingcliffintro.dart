import 'package:calm_quest/achievements_system.dart';
import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../storage.dart';
import 'calming_cliffs_activity.dart';

class CalmingCliffsIntro extends StatefulWidget {
  const CalmingCliffsIntro({super.key});

  @override
  _CalmingCliffsIntroState createState() => _CalmingCliffsIntroState();
}

class _CalmingCliffsIntroState extends State<CalmingCliffsIntro>
    with TickerProviderStateMixin {
  bool _activityCompleted = false;

  // Timers & booleans to fade in text & card
  bool _isTextVisible = false;
  bool _isBlurbVisible = false;

  // Parallax alignment animation controllers
  late AnimationController _mountainDriftController;
  late AnimationController _steamDriftController;
  late Animation<Alignment> _mountainAlign;
  late Animation<Alignment> _steamAlign1;
  late Animation<Alignment> _steamAlign2;

  // NEW: Single "bobbing" icon instead of multiple small rotating icons
  late AnimationController _bobController;
  late Animation<double> _bobAnimation;

  @override
  void initState() {
    super.initState();

    // Schedule the staged appearances
    Timer(const Duration(milliseconds: 500), () {
      setState(() => _isTextVisible = true);
    });
    Timer(const Duration(milliseconds: 1200), () {
      setState(() => _isBlurbVisible = true);
    });

    // 1) Parallax BG alignment
    _mountainDriftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _steamDriftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _mountainAlign = AlignmentTween(
      begin: const Alignment(-0.2, 0),
      end: const Alignment(0.2, 0),
    ).animate(
      CurvedAnimation(
        parent: _mountainDriftController,
        curve: Curves.easeInOut,
      ),
    );

    _steamAlign1 = AlignmentTween(
      begin: const Alignment(-0.3, 0),
      end: const Alignment(0.3, 0),
    ).animate(
      CurvedAnimation(
        parent: _steamDriftController,
        curve: Curves.easeInOut,
      ),
    );

    _steamAlign2 = AlignmentTween(
      begin: const Alignment(0.3, 0),
      end: const Alignment(-0.3, 0),
    ).animate(
      CurvedAnimation(
        parent: _steamDriftController,
        curve: Curves.easeInOut,
      ),
    );

    // 2) Bobbing icon
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Bobs ~10px up/down (0 => 10 => 0 => -10 => 0, etc.)
    _bobAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _bobController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _mountainDriftController.dispose();
    _steamDriftController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  Future<void> setActivityCompleted(Future<dynamic> val) async {
    _activityCompleted = (await val) as bool;
    setState(() {});

    if(_activityCompleted){
      Storage.storage.addActivityLog(ActivityName.calming_cliffs, '');
      AchievementsSystem.updateAchievementCondition(Achievement.Calming_Shield, 1);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Make the app bar transparent + white icons:
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Calming Cliffs', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // back arrow in white
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, _activityCompleted);
          },
        ),
      ),

      body: Stack(
        children: [
          // Mountains BG
          AnimatedBuilder(
            animation: _mountainAlign,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: _mountainAlign.value,
                    image: const AssetImage('assets/gamify/OrangeMountainFull.png'),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              );
            },
          ),

          // Steam layer 1
          AnimatedBuilder(
            animation: _steamAlign1,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: _steamAlign1.value,
                    image: const AssetImage('assets/gamify/OrangeSteam1.png'),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              );
            },
          ),

          // Steam layer 2
          AnimatedBuilder(
            animation: _steamAlign2,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    alignment: _steamAlign2.value,
                    image: const AssetImage('assets/gamify/OrangeSteam2.png'),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              );
            },
          ),

          // Dark overlay behind app bar + content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B2D00).withOpacity(0.5),
                  const Color(0xFFB33F09).withOpacity(0.5),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Main content area
          SafeArea(
            child: Column(
              // push everything down from the top so it doesn't overlap the app bar
              children: [
                // A little spacing so we don't start right under the app bar
                const SizedBox(height: 100),

                // Single bobbing icon
                AnimatedBuilder(
                  animation: _bobAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, -_bobAnimation.value),
                      child: const Icon(
                        Icons.terrain,
                        size: 80,
                        color: Colors.white,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50),

                // Fade-in "Welcome" card
                AnimatedOpacity(
                  opacity: _isTextVisible ? 1.0 : 0.0,
                  duration: const Duration(seconds: 2),
                  curve: Curves.easeInOut,
                  child: Card(
                    color: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Welcome to Calming Cliffs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Start button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CalmingCliffsActivity(),
                      ),
                    ).then((value) {
                      setActivityCompleted(Future.value(value));
                    });
                  },
                  child: const Text('Start'),
                ),

                const SizedBox(height: 30),

                // Fade-in descriptive text
                AnimatedOpacity(
                  opacity: _isBlurbVisible ? 1.0 : 0.0,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Calming Cliffs is your sanctuary for relaxation and mindfulness. '
                          'In this activity, you\'ll engage in soothing exercises designed '
                          'to help you unwind and connect with your inner peace. Get ready '
                          'to embark on a tranquil journey and find serenity amidst the cliffs!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
