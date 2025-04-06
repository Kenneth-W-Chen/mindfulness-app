import 'package:calm_quest/storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class BreathingActivity extends StatefulWidget {
  const BreathingActivity({super.key});

  @override
  _BreathingActivityState createState() => _BreathingActivityState();
}

class _BreathingActivityState extends State<BreathingActivity>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathingAnimation;
  bool _activityCompleted = false;
  String _instruction = 'Inhale...';
  late Timer _breathingTimer;
  late Timer completionTimer;

  @override
  void initState() {
    super.initState();

    // Animation controller for smooth breathing effect
    _controller = AnimationController(
      duration: const Duration(seconds: 4), // For inhale and exhale
      vsync: this,
    );

    _breathingAnimation = Tween<double>(begin: 90.0, end: 190.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    completionTimer = Timer(const Duration(seconds: 30), () async {
      _activityCompleted = true;
      setState(() {});
      Storage.storage.addActivityLog(ActivityName.breathe, '');
    });
    _startBreathingSequence();
  }

  void _startBreathingSequence() {
    int step = 0; // Step to track inhale, hold, and exhale

    _breathingTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (step == 0) {
        // Inhale
        setState(() {
          _instruction = 'Inhale...';
        });
        _controller.duration =
            const Duration(seconds: 4); // 4 seconds for inhale
        _controller.forward();
        step++;
      } else if (step == 1) {
        // Hold (1 second)
        setState(() {
          _instruction = 'Hold...';
        });
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            step++;
          });
        });
      } else if (step == 2) {
        // Exhale
        setState(() {
          _instruction = 'Exhale...';
        });
        _controller.duration =
            const Duration(seconds: 4); // 4 seconds for exhale
        _controller.reverse();
        step = 0; // Loop back to inhale
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathingTimer.cancel();
    completionTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF87CEFA), // Light sky blue
              Color(0xFF4682B4), // Deep sky blue
              Color(0xFFFFF8DC), // Sandy beach color
            ],
            stops: [0.0, 0.7, 1.0], // Gradient stops for smooth transitions
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 70),
            Text(
              'Breathing Activity',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'BubbleFont',
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _instruction,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _breathingAnimation,
                    builder: (context, child) {
                      return Center(
                        child: Container(
                          width: _breathingAnimation.value,
                          height: _breathingAnimation.value,
                          decoration: BoxDecoration(
                            color: Colors.yellow.withOpacity(0.8),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellow.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _activityCompleted);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFF8DC), // Sandy color
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(
                  color: Color(0xFF4682B4),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
