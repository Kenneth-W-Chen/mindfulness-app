import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'calming_cliffs_activity.dart'; // Correct relative path to the activity

class CalmingCliffsIntro extends StatefulWidget {
  const CalmingCliffsIntro({Key? key}) : super(key: key);

  @override
  _CalmingCliffsIntroState createState() => _CalmingCliffsIntroState();
}

class _CalmingCliffsIntroState extends State<CalmingCliffsIntro>
    with TickerProviderStateMixin {
  bool _activityCompleted = false;
  bool _isTextVisible = false;
  bool _isMountainScaled = false;
  bool _isBlurbVisible = false;
  late AnimationController _fadeController;
  late AnimationController _leftMountainController;
  late AnimationController _rightMountainController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _isMountainScaled = true;
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

    _leftMountainController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _rightMountainController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_fadeController);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _leftMountainController.dispose();
    _rightMountainController.dispose();
    super.dispose();
  }

  Future<void> setActivityCompleted(Future<dynamic> val) async {
    _activityCompleted = (await val) as bool;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: activityAppBar(
          'Calming Cliffs', Colors.deepOrange[800]!, context, _activityCompleted),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrange],
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
                    turns: _leftMountainController,
                    child: const Icon(
                      Icons.landscape,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                AnimatedScale(
                  scale: _isMountainScaled ? 1.2 : 0.8,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.terrain,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(width: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: RotationTransition(
                    turns: _rightMountainController,
                    child: const Icon(
                      Icons.landscape,
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                foregroundColor: Colors.deepOrangeAccent,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalmingCliffsActivity()),
                ).then((value) {
                  setActivityCompleted(Future.value(value));
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
                  'Calming Cliffs is your sanctuary for relaxation and mindfulness. In this activity, you\'ll engage in soothing exercises designed to help you unwind and connect with your inner peace. Get ready to embark on a tranquil journey and find serenity amidst the cliffs!',
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
