import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'mellowmazeactivity.dart'; // Correct relative path to the activity

class MellowMazeIntro extends StatefulWidget {
  const MellowMazeIntro({Key? key}) : super(key: key);

  @override
  _MellowMazeIntroState createState() => _MellowMazeIntroState();
}

class _MellowMazeIntroState extends State<MellowMazeIntro>
    with TickerProviderStateMixin {
  bool _activityCompleted = false;
  bool _isTextVisible = false;
  bool _isMazeScaled = false;
  bool _isBlurbVisible = false;
  late AnimationController _fadeController;
  late AnimationController _leftMazeController;
  late AnimationController _rightMazeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _isMazeScaled = true;
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

    _leftMazeController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _rightMazeController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_fadeController);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _leftMazeController.dispose();
    _rightMazeController.dispose();
    super.dispose();
  }

  Future<void> setActivityCompleted(Future<dynamic> val) async {
    _activityCompleted = (await val) as bool;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mellow Maze',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.teal[800],
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent, Colors.teal],
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
                    turns: _leftMazeController,
                    child: const Icon(
                      Icons.all_inclusive,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                AnimatedScale(
                  scale: _isMazeScaled ? 1.2 : 0.8,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.blur_circular,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
                const SizedBox(width: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: RotationTransition(
                    turns: _rightMazeController,
                    child: const Icon(
                      Icons.all_inclusive,
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
                color: Colors.tealAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'Welcome to Mellow Maze',
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
                foregroundColor: Colors.teal,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MellowMazeActivity()),
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
                  'Mellow Maze is your path to clarity. Traverse the maze and find tranquility in its winding paths.',
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