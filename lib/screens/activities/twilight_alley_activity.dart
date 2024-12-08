import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'twilight_alley_intro.dart'; // Ensure the import path is correct
import '../../storage.dart';

class TwilightAlleyActivity extends StatefulWidget {
  const TwilightAlleyActivity({Key? key}) : super(key: key);

  @override
  _TwilightAlleyActivityState createState() => _TwilightAlleyActivityState();
}

class _TwilightAlleyActivityState extends State<TwilightAlleyActivity>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _leftStarController;
  late AnimationController _rightStarController;
  late Animation<double> _fadeAnimation;
  bool _activityCompleted = false;
  final List<String> _prompts = [
    "What made you smile today?",
    "What is something you're grateful for?",
    "What is one thing you would like to achieve this week?",
    "Describe a moment where you felt proud.",
    "What would you say to your future self?"
  ];
  int _currentPromptIndex = 0;
  final List<String> _userResponses = [];
  final TextEditingController _textController = TextEditingController();
  bool _isPromptVisible = true;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(seconds: 3), // Slower fading for stars
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
    _textController.dispose();
    super.dispose();
  }

  Future<void> _getNextPrompt() async {
    if (_currentPromptIndex < 4) {
      // Hide the current prompt immediately
      setState(() {
        _isPromptVisible = false;
      });

      // Wait for the current prompt to disappear
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear the text controller before showing the next prompt
      _textController.clear();

      // Show the next prompt after a delay
      setState(() {
        _currentPromptIndex++;
        _isPromptVisible = true;
      });
    } else {
      _activityCompleted = true;
      var storage = await Storage.create();
      var future = storage.addActivityLog(ActivityName.twilight_alley, _userResponses.join('\n'));
      // Logic for end of prompts (e.g., navigate to a summary page)
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Session Complete"),
            content: Text("Your responses:\n${_userResponses.join("\n")}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context,true);
                  /*Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TwilightAlleyIntro(),
                    ),
                  );*/
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
      await future;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: activityAppBar('Twilight Alley', Colors.deepPurple[800]!, context, _activityCompleted),
      body: Container(
        width: double.infinity, // Ensures the container covers full width
        height: double.infinity, // Ensures the container covers full height
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
            const SizedBox(height: 50), // Space to push the icons away from the top
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
                  scale: 1.2,
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
            const SizedBox(height: 30), // Space between the icons and the prompt
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isPromptVisible ? 1.0 : 0.0,
              child: Padding(
                key: ValueKey<int>(_currentPromptIndex),
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _prompts[_currentPromptIndex],
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20), // Space between the prompt and text field
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _isPromptVisible ? 1.0 : 0.0,
              child: Padding(
                key: ValueKey<int>(_currentPromptIndex),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    hintText: 'Type your response here...',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Space between text field and button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent, // Button background color
                foregroundColor: Colors.white, // Text color
              ),
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _userResponses.add(_textController.text);
                  _getNextPrompt();
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
