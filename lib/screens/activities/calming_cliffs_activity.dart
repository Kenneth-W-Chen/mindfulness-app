import 'package:flutter/material.dart';
import 'dart:math';

class CalmingCliffsActivity extends StatefulWidget {
  const CalmingCliffsActivity({Key? key}) : super(key: key);

  @override
  _CalmingCliffsActivityState createState() => _CalmingCliffsActivityState();
}

class _CalmingCliffsActivityState extends State<CalmingCliffsActivity>
    with TickerProviderStateMixin {
  // Controllers for the activity
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;

  late AnimationController _iconController;
  late Animation<double> _iconScaleAnimation;

  int _currentPhraseIndex = 0;

  // Updated list of 12 existentially calming statements
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

  // Mapping phrases to icons
  final Map<String, IconData> _phraseIcons = {
    "You are a tiny part of an immense universe.": Icons.public,
    "The stars you see have shone for millions of years.": Icons.star,
    "Every atom in your body came from a star that exploded.": Icons.whatshot,
    "The Earth is but a speck in the vast cosmos.": Icons.public,
    "Your worries are small compared to the grandeur of the universe.": Icons.grain,
    "In the timeline of the universe, our lives are but a blink.": Icons.access_time,
    "We are all connected by the atoms that make up everything.": Icons.scatter_plot,
    "The universe is vast, and you are a part of its story.": Icons.menu_book,
    "Look at the night sky and feel the infinite possibilities.": Icons.nights_stay,
    "The cosmos is within us; we are made of star-stuff.": Icons.brightness_5,
    "The pale blue dot is our only home.": Icons.home,
    "Among billions of galaxies, we share this moment.": Icons.people,
  };

  // List to hold the 5 randomly selected phrases for the session
  late List<String> _sessionPhrases;

  final Duration _phraseDuration = const Duration(seconds: 5);
  final Duration _fadeDuration = const Duration(seconds: 2);

  @override
  void initState() {
    super.initState();

    // Randomly select 5 phrases from the list for the session
    _sessionPhrases = _getRandomPhrases();

    // Background gradient animation controller
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = _backgroundController.drive(
      ColorTween(
        begin: Colors.orangeAccent,
        end: Colors.deepOrange,
      ),
    );

    // Text fade animation controller
    _textController = AnimationController(
      duration: _fadeDuration,
      vsync: this,
    );

    _textFadeAnimation = _textController.drive(
      Tween<double>(begin: 0.0, end: 1.0),
    );

    // Icon scale animation controller
    _iconController = AnimationController(
      duration: _fadeDuration,
      vsync: this,
    );

    _iconScaleAnimation = _iconController.drive(
      Tween<double>(begin: 0.8, end: 1.2),
    );

    // Start the first phrase animation
    _startPhraseAnimation();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _textController.dispose();
    _iconController.dispose();
    super.dispose();
  }

  // Method to randomly select 5 phrases
  List<String> _getRandomPhrases() {
    final random = Random();
    final phrasesCopy = List<String>.from(_calmingPhrases);
    phrasesCopy.shuffle(random);
    return phrasesCopy.take(5).toList();
  }

  void _startPhraseAnimation() {
    _textController.forward();
    _iconController.forward();

    Future.delayed(_phraseDuration, () {
      _textController.reverse();
      _iconController.reverse().then((_) {
        setState(() {
          _currentPhraseIndex++;
          if (_currentPhraseIndex < _sessionPhrases.length) {
            _startPhraseAnimation();
          } else {
            // All phrases have been displayed; navigate back to intro screen
            Navigator.pop(context, true); // Pass back 'true' to indicate completion
          }
        });
      });
    });
  }

  double _getProgress() {
    return (_currentPhraseIndex + _textController.value) / _sessionPhrases.length;
  }

  @override
  Widget build(BuildContext context) {
    final currentPhrase = _sessionPhrases[_currentPhraseIndex % _sessionPhrases.length];
    final currentIcon = _phraseIcons[currentPhrase] ?? Icons.lightbulb;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _backgroundAnimation.value ?? Colors.orangeAccent,
                  Colors.white,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _iconScaleAnimation,
                child: Icon(
                  currentIcon,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              FadeTransition(
                opacity: _textFadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    currentPhrase,
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: LinearProgressIndicator(
                  value: _getProgress(),
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
