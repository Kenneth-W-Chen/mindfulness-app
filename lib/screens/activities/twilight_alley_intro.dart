import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../shared/twilight_alley_load.dart'; // Correct relative path to the load screen
import 'twilight_alley_activity.dart'; // Correct relative path to the activity

class TwilightAlleyIntro extends StatefulWidget {
  const TwilightAlleyIntro({Key? key}) : super(key: key);

  @override
  _TwilightAlleyIntroState createState() => _TwilightAlleyIntroState();
}

class _TwilightAlleyIntroState extends State<TwilightAlleyIntro>
    with TickerProviderStateMixin {
  bool _activityCompleted = false;
  bool _isTextVisible = false;
  bool _isMoonScaled = false;
  bool _isBlurbVisible = false;
  late AnimationController _fadeController;
  late AnimationController _leftStarController;
  late AnimationController _rightStarController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _isMoonScaled = true;
      });
    });
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _isTextVisible = true;
      });
    });
    Timer(const Duration(milliseconds: 1700), () {
      setState(() {
        _isBlurbVisible = true;
      });
    });

    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _leftStarController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _rightStarController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(_fadeController);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _leftStarController.dispose();
    _rightStarController.dispose();
    super.dispose();
  }

  Future<void> setActivityCompleted(Future<dynamic> val) async{
    _activityCompleted = (await val) as bool;
    debugPrint("Activity is ${_activityCompleted?'complete':'not complete'}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: activityAppBar('Twilight Alley', Colors.deepPurple[800]!, context, _activityCompleted),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: RotationTransition(
                    turns: _leftStarController,
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                AnimatedScale(
                  scale: _isMoonScaled ? 1.2 : 0.8,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.nightlight_round,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(width: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: RotationTransition(
                    turns: _rightStarController,
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            AnimatedOpacity(
              opacity: _isTextVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              child: Card(
                color: Colors.deepPurpleAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Welcome to Twilight Alley',
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                foregroundColor: Colors.deepPurpleAccent,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TwilightAlleyLoad()),
                );
                Timer(const Duration(milliseconds: 3500), () {
                  setActivityCompleted(Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TwilightAlleyActivity()),
                  ));
                });
              },
              child: const Text('Start'),
            ),
            const SizedBox(height: 20),
            AnimatedOpacity(
              opacity: _isBlurbVisible ? 1.0 : 0.0,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Twilight Alley is your space for creative reflection. In this mini-game, you\'ll be prompted with fun, thought-provoking questions. Enter your responses and see how your insights stack up. Get ready to discover more about yourself and have fun while doing it!',
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
    );
  }
}
