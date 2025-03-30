import 'package:flutter/material.dart';
import 'dart:math';

import '../../storage.dart';

class CalmingCliffsActivity extends StatefulWidget {
  const CalmingCliffsActivity({Key? key}) : super(key: key);

  @override
  _CalmingCliffsActivityState createState() => _CalmingCliffsActivityState();
}

class _CalmingCliffsActivityState extends State<CalmingCliffsActivity>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;
  late AnimationController _breathingController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  late AnimationController _ballGradientController;

  int _currentBreathingIndex = 0;
  int _currentPhraseIndex = 0;
  final List<String> _breathingSteps = ["Inhale", "Hold", "Exhale", "Hold"];

  // Key positions along the square's border.
  final List<Alignment> _squarePositions = [
    Alignment(0, -1), // top center
    Alignment(1, 0),  // right center
    Alignment(0, 1),  // bottom center
    Alignment(-1, 0), // left center
  ];

  final List<String> _calmingPhrases = [
    "You are a tiny part of an immense universe.",
    "The stars you see have shone for millions of years.",
    "Every atom in your body came from a star that exploded.",
    "The Earth is but a speck in the vast cosmos.",
    "Your worries are small compared to the grandeur of the universe.",
    "In the timeline of the universe, our lives are but a blink.",
    "We are all connected by the atoms that make up everything.",
    "The universe is vast, and you are a part of its story.",
    "Look at the night sky and feel the infinite possibilities.",
    "The cosmos is within us; we are made of star-stuff.",
    "The pale blue dot is our only home.",
    "Among billions of galaxies, we share this moment.",
  ];

  late final Storage _storage;

  @override
  void initState() {
    super.initState();

    // Background gradient animation.
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _backgroundAnimation = _backgroundController.drive(
      ColorTween(
        begin: Colors.orangeAccent,
        end: Colors.deepOrangeAccent,
      ),
    );

    // Breathing controller (16-second cycle).
    _breathingController = AnimationController(
      duration: const Duration(seconds: 16),
      vsync: this,
    )
      ..addListener(() {
        int newIndex = min(
          (_breathingController.value * _breathingSteps.length).floor(),
          _breathingSteps.length - 1,
        );
        if (newIndex != _currentBreathingIndex) {
          setState(() {
            _currentBreathingIndex = newIndex;
            if (newIndex == 0) {
              _currentPhraseIndex =
                  (_currentPhraseIndex + 1) % _calmingPhrases.length;
            }
          });
        }
      })
      ..repeat();

    // Overall progress (60-second activity).
    _progressController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _progressController.forward().then((_) async {
      await _storage.addActivityLog(ActivityName.calming_cliffs, '');
      Navigator.pop(context, true);
    });
    _progressAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_progressController);

    // Ball gradient animation (shifting between yellow and white).
    _ballGradientController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
  }

  // Computes the ball's alignment along the square's border.
  Alignment getSquareAlignment(double t) {
    t = t % 1.0;
    if (t < 0.25) {
      double localT = t / 0.25;
      return Alignment.lerp(_squarePositions[0], _squarePositions[1], localT)!;
    } else if (t < 0.5) {
      double localT = (t - 0.25) / 0.25;
      return Alignment.lerp(_squarePositions[1], _squarePositions[2], localT)!;
    } else if (t < 0.75) {
      double localT = (t - 0.5) / 0.25;
      return Alignment.lerp(_squarePositions[2], _squarePositions[3], localT)!;
    } else {
      double localT = (t - 0.75) / 0.25;
      return Alignment.lerp(_squarePositions[3], _squarePositions[0], localT)!;
    }
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _breathingController.dispose();
    _progressController.dispose();
    _ballGradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      // Transparent AppBar with a quit button.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          //** Fix: Return false when back button is pressed to avoid null value error.
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _backgroundAnimation.value ?? Colors.orangeAccent,
                  Colors.deepOrangeAccent,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mountain icon pulsing with remaining time.
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _breathingController,
                    builder: (context, child) {
                      double scale =
                          1.0 + 0.1 * sin(2 * pi * _breathingController.value);
                      return Transform.scale(
                        scale: scale,
                        child: const Icon(
                          Icons.filter_hdr,
                          size: 48,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      int remainingMillis =
                      (60000 * (1 - _progressController.value)).round();
                      Duration remaining =
                      Duration(milliseconds: remainingMillis);
                      int minutes = remaining.inMinutes;
                      int seconds = remaining.inSeconds % 60;
                      String timeStr =
                          "$minutes:${seconds.toString().padLeft(2, '0')}";
                      return Text(
                        timeStr,
                        style:
                        const TextStyle(color: Colors.white, fontSize: 20),
                      );
                    },
                  ),
                ],
              ),
              // Main content: breathing text, calming phrase, and animated square.
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Breathing prompt.
                    AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: Text(
                        _breathingSteps[_currentBreathingIndex],
                        key: ValueKey<int>(_currentBreathingIndex),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Calming phrase.
                    AnimatedSwitcher(
                      duration: const Duration(seconds: 1),
                      child: Text(
                        _calmingPhrases[_currentPhraseIndex],
                        key: ValueKey<int>(_currentPhraseIndex),
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Hollow square with the tracing ball.
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: AnimatedBuilder(
                        animation: Listenable.merge(
                            [_breathingController, _ballGradientController]),
                        builder: (context, child) {
                          Alignment ballAlignment =
                          getSquareAlignment(_breathingController.value);
                          return Align(
                            alignment: ballAlignment,
                            child: AnimatedBuilder(
                              animation: _ballGradientController,
                              builder: (context, child) {
                                double t = _ballGradientController.value;
                                Color startColor =
                                Color.lerp(Colors.yellow, Colors.white, t)!;
                                Color endColor =
                                Color.lerp(Colors.white, Colors.yellow, t)!;
                                return Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [startColor, endColor],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Progress bar.
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
