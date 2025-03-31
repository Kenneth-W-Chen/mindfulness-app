import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'twilight_alley_intro.dart';
import '../../storage.dart';
import 'package:dart_sentiment/dart_sentiment.dart';

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

  // New variables for points, sentiment, and sad emoji detection
  int _totalEmojiPoints = 0;
  bool _sadEmojiSelected = false;
  int _cumulativeSentimentScore = 0; // cumulative sentiment score
  final Map<String, int> _emojiPoints = {
    "happy": 3,
    "neutral": 2,
    "sad": 1,
  };

  // Create a Sentiment analyzer instance
  final Sentiment sentiment = Sentiment();

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

      // Save the activity log as before
      var future = storage.addActivityLog(
        ActivityName.twilight_alley,
        [
          ..._userResponses,
          ..._emojiResponses,
          pointsMessage,
          'Sad Emoji Selected: ${_sadEmojiSelected ? 'Yes' : 'No'}',
          'Cumulative Sentiment Score: $_cumulativeSentimentScore',
        ].join('\n'),
      );

      // Instead of a dialog, navigate to a summary screen that uses the same styling.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SessionSummaryScreen(
            userResponses: _userResponses,
            emojiResponses: _emojiResponses,
            pointsMessage: pointsMessage,
            sadEmojiSelected: _sadEmojiSelected,
            cumulativeSentimentScore: _cumulativeSentimentScore,
          ),
        ),
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
        _getNextPrompt(); // Transition to the summary screen
      }
    });
  }

  // Widget to build animated sentiment gauge (text label)
  Widget _buildSentimentGauge() {
    Color scoreColor;
    if (_cumulativeSentimentScore > 0) {
      scoreColor = Colors.green;
    } else if (_cumulativeSentimentScore < 0) {
      scoreColor = Colors.red;
    } else {
      scoreColor = Colors.grey;
    }
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 500),
      style: TextStyle(
        fontSize: 20,
        color: scoreColor,
        fontWeight: FontWeight.bold,
      ),
      child: Text("Cumulative Sentiment Score: $_cumulativeSentimentScore"),
    );
  }

  // Widget to build animated sentiment bar showing negative and positive proportions.
  Widget _buildSentimentBar(BuildContext context) {
    double maxScore = 20.0; // Maximum absolute score assumed for display
    double totalWidth = MediaQuery.of(context).size.width - 40; // Some padding
    double center = totalWidth / 2;
    double positiveWidth = 0.0;
    double negativeWidth = 0.0;
    if (_cumulativeSentimentScore > 0) {
      positiveWidth =
      (totalWidth * (_cumulativeSentimentScore.clamp(0, maxScore) / maxScore));
    } else if (_cumulativeSentimentScore < 0) {
      negativeWidth =
      (totalWidth * ((-_cumulativeSentimentScore).clamp(0, maxScore) / maxScore));
    }
    return Column(
      children: [
        Container(
          width: totalWidth,
          height: 10,
          color: Colors.grey[300],
          child: Stack(
            children: [
              Positioned(
                left: center - negativeWidth,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: negativeWidth,
                  height: 10,
                  color: Colors.red,
                ),
              ),
              Positioned(
                left: center,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: positiveWidth,
                  height: 10,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _buildSentimentGauge(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: activityAppBar(
          'Twilight Alley', Colors.deepPurple[800]!, context, _activityCompleted),
      body: Container(
        width: double.infinity, // Full width
        height: double.infinity, // Full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          // For smaller screens
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Display live sentiment bar at the top
              const SizedBox(height: 20),
              _buildSentimentBar(context),
              const SizedBox(height: 20),
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
              // Analyze sentiment of the input and update cumulative score
              final result = sentiment.analysis(_textController.text, emoji: true);
              int score = result['score'] as int;
              setState(() {
                _cumulativeSentimentScore += score;
              });

              _userResponses.add(_textController.text);
              _getNextPrompt();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
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
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 30),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: _isPromptVisible ? 1.0 : 0.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.sentiment_very_satisfied,
                    size: 60, color: Colors.green),
                onPressed: () => _handleEmojiResponse("happy"),
              ),
              IconButton(
                icon: const Icon(Icons.sentiment_neutral,
                    size: 60, color: Colors.yellow),
                onPressed: () => _handleEmojiResponse("neutral"),
              ),
              IconButton(
                icon: const Icon(Icons.sentiment_dissatisfied,
                    size: 60, color: Colors.red),
                onPressed: () => _handleEmojiResponse("sad"),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// New: A screen to display the session summary with matching styling and animations.
class SessionSummaryScreen extends StatelessWidget {
  final List<String> userResponses;
  final List<String> emojiResponses;
  final String pointsMessage;
  final bool sadEmojiSelected;
  final int cumulativeSentimentScore;

  const SessionSummaryScreen({
    Key? key,
    required this.userResponses,
    required this.emojiResponses,
    required this.pointsMessage,
    required this.sadEmojiSelected,
    required this.cumulativeSentimentScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Reuse the same background gradient
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated title
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 500),
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  child: const Text("Session Summary"),
                ),
                const SizedBox(height: 20),
                // Display cumulative sentiment with animated gauge
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 500),
                  style: TextStyle(
                    fontSize: 20,
                    color: cumulativeSentimentScore > 0
                        ? Colors.green
                        : (cumulativeSentimentScore < 0 ? Colors.red : Colors.grey),
                    fontWeight: FontWeight.bold,
                  ),
                  child: Text("Cumulative Sentiment Score: $cumulativeSentimentScore"),
                ),
                const SizedBox(height: 10),
                // Points message
                Text(
                  pointsMessage,
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // Sad emoji indicator
                Text(
                  "Sad Emoji Selected: ${sadEmojiSelected ? 'Yes' : 'No'}",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const Divider(color: Colors.white54, height: 40),
                // Display text responses
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Text Responses:",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...userResponses.map((response) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    response,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )),
                const Divider(color: Colors.white54, height: 40),
                // Display emoji responses
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Emoji Responses:",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ...emojiResponses.map((response) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    response,
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurpleAccent,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Finish"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
