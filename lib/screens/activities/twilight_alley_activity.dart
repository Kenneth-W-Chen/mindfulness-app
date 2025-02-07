import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
// Ensure the import path is correct
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

  final List<String> _emojiPrompts = [
    "How satisfied are you with your day?",
    "How do you feel about your progress this week?",
    "Are you happy with your accomplishments today?",
    "Do you feel motivated for tomorrow?",
    "How connected do you feel to your goals?"
  ];
  int _currentEmojiPromptIndex = 0;
  final List<String> _emojiResponses = [];

  // New variables for points and sad emoji detection
  int _totalEmojiPoints = 0;
  bool _sadEmojiSelected = false;
  final Map<String, int> _emojiPoints = {
    "happy": 3,
    "neutral": 2,
    "sad": 1,
  };

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

    _fadeAnimation =
        Tween<double>(begin: 0.3, end: 1.0).animate(_fadeController);
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
    if (_currentPromptIndex < _prompts.length) {
      // Allow completion of all text prompts
      setState(() {
        _isPromptVisible = false;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      _textController.clear();

      setState(() {
        _currentPromptIndex++;
        _isPromptVisible = true;
      });
    } else if (_currentEmojiPromptIndex < _emojiPrompts.length) {
      // Move to emoji prompts
      setState(() {
        _isPromptVisible = false; // Hide previous prompt
      });
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isPromptVisible = true; // Show emoji prompt
      });
    } else {
      _activityCompleted = true;
      var storage = await Storage.create();

      // Prepare the points message
      String pointsMessage = _totalEmojiPoints < 13
          ? 'Total Emoji Points: $_totalEmojiPoints (Less than 13)'
          : 'Total Emoji Points: $_totalEmojiPoints';

      var future = storage.addActivityLog(
        ActivityName.twilight_alley,
        [
          ..._userResponses,
          ..._emojiResponses,
          pointsMessage,
          'Sad Emoji Selected: ${_sadEmojiSelected ? 'Yes' : 'No'}',
        ].join('\n'),
      );
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Session Complete"),
            content: Text(
              "Your responses:\n"
                  "${_userResponses.join("\n")}\n"
                  "${_emojiResponses.join("\n")}\n\n"
                  "$pointsMessage\n"
                  "Sad Emoji Selected: ${_sadEmojiSelected ? 'Yes' : 'No'}",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pop(context, true);
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

  void _handleEmojiResponse(String response) {
    setState(() {
      _emojiResponses.add(response);
      _totalEmojiPoints += _emojiPoints[response]!; // Update total points

      if (response == "sad") {
        _sadEmojiSelected = true; // Mark that the red emoji was selected
      }

      if (_currentEmojiPromptIndex < _emojiPrompts.length - 1) {
        _isPromptVisible = false; // Fade out current prompt

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _currentEmojiPromptIndex++;
            _isPromptVisible = true; // Fade in next prompt
          });
        });
      } else {
        _currentEmojiPromptIndex++; // Increment index to move beyond last prompt
        _activityCompleted = true;
        _getNextPrompt(); // Transition to the completion dialog
      }
    });
  }

  Widget _buildEmojiPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _isPromptVisible ? 1.0 : 0.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _emojiPrompts[_currentEmojiPromptIndex],
              style: const TextStyle(
                fontSize: 26, // Increased font size
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 30), // Increased space between text and icons
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _isPromptVisible ? 1.0 : 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.sentiment_very_satisfied,
                    size: 60, color: Colors.green), // Increased size
                onPressed: () => _handleEmojiResponse("happy"),
              ),
              IconButton(
                icon: const Icon(Icons.sentiment_neutral,
                    size: 60, color: Colors.yellow), // Increased size
                onPressed: () => _handleEmojiResponse("neutral"),
              ),
              IconButton(
                icon: const Icon(Icons.sentiment_dissatisfied,
                    size: 60, color: Colors.red), // Increased size
                onPressed: () => _handleEmojiResponse("sad"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: activityAppBar('Twilight Alley', Colors.deepPurple[800]!,
          context, _activityCompleted),
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
            if (_currentPromptIndex < _prompts.length) ...[
              const SizedBox(height: 50),
              _buildTextPrompt(),
            ] else if (_currentEmojiPromptIndex < _emojiPrompts.length) ...[
              const SizedBox(height: 50),
              _buildEmojiPrompt(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextPrompt() {
    return Column(
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
        const SizedBox(height: 30),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _isPromptVisible ? 1.0 : 0.0,
          child: Padding(
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
        const SizedBox(height: 20),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _isPromptVisible ? 1.0 : 0.0,
          child: Padding(
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
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            foregroundColor: Colors.white,
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
    );
  }
}
