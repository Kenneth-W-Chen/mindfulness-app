// mellowmazeactivity.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'mellowmazeEngine.dart';
import 'mellowmazemini.dart'; // Import the minigame widgets

enum MazeStage { introduction, questions, reflection }

class MellowMazeActivity extends StatefulWidget {
  const MellowMazeActivity({super.key});

  @override
  _MellowMazeActivityState createState() => _MellowMazeActivityState();
}

class _MellowMazeActivityState extends State<MellowMazeActivity>
    with TickerProviderStateMixin {
  MazeStage _currentStage = MazeStage.introduction;
  int _currentQuestionIndex = 0;
  double _concentration = 1.0; // Health bar value (0.0 to 1.0)
  double _targetConcentration = 1.0;
  int _wrongAnswersCount = 0; // Count of wrong answers
  bool _minigamePlayed = false; // Only one breathing minigame per level

  // For this example, we load the first level.
  final MellowMazeLevel level = levels[0];

  // Overall background animation controllers.
  late AnimationController _backgroundController;
  late Animation<Color?> _backgroundAnimation;

  // Top gradient (maze floor) animated via a cool-spectrum cycle.
  late AnimationController _topGradientController;

  // Text fade animation for transitions.
  late AnimationController _textController;
  late Animation<double> _textFadeAnimation;

  // Health bar animation.
  late AnimationController _healthController;
  late Animation<double> _healthAnimation;

  @override
  void initState() {
    super.initState();

    // Overall background: transitions between two shades of teal.
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _backgroundAnimation = _backgroundController.drive(
      ColorTween(begin: Colors.teal, end: Colors.tealAccent),
    );

    // Top gradient: continuously cycles through cool hues.
    _topGradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    // Text fade animation for question transitions.
    _textController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _textFadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_textController);
    _textController.forward();

    // Health bar animation with a smooth curve.
    _healthController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _healthAnimation =
        Tween<double>(begin: _concentration, end: _concentration).animate(
      CurvedAnimation(parent: _healthController, curve: Curves.easeInOut),
    )..addListener(() {
            setState(() {});
          });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _topGradientController.dispose();
    _textController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  /// Silently resets the activity to the introduction stage.
  void _resetActivity() {
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _currentStage = MazeStage.introduction;
        _currentQuestionIndex = 0;
        _concentration = 1.0;
        _targetConcentration = 1.0;
        _wrongAnswersCount = 0;
        _minigamePlayed = false;
        _textController.reset();
        _textController.forward();
      });
    });
  }

  /// Begins the adventure by switching from introduction to questions.
  void _startAdventure() {
    setState(() {
      _currentStage = MazeStage.questions;
      _currentQuestionIndex = 0;
      _concentration = 1.0;
      _targetConcentration = 1.0;
      _wrongAnswersCount = 0;
      _minigamePlayed = false;
      _textController.reset();
      _textController.forward();
    });
  }

  /// Computes a horizontal alignment for the animated runner.
  /// Moves from left (-1.0) to right (1.0) based on question progress.
  Alignment _getMazeAlignment() {
    double progress = level.questions.length > 1
        ? _currentQuestionIndex / (level.questions.length - 1)
        : 0.0;
    double alignmentX = -1.0 + 2.0 * progress;
    // Vertical alignment fixed at 1.0 (bottom of the container).
    return Alignment(alignmentX, 1.0);
  }

  /// Handles answer selection.
  void _handleAnswer(int choiceIndex) {
    final currentQuestion = level.questions[_currentQuestionIndex];

    if (choiceIndex != currentQuestion.correctIndex) {
      setState(() {
        _wrongAnswersCount++;
        _targetConcentration -= 0.34;
        if (_targetConcentration < 0) _targetConcentration = 0;
        _healthAnimation = Tween<double>(
          begin: _concentration,
          end: _targetConcentration,
        ).animate(
          CurvedAnimation(parent: _healthController, curve: Curves.easeInOut),
        )..addListener(() {
            setState(() {});
          });
        _healthController.forward(from: 0);
      });
      if (_wrongAnswersCount >= 3) {
        _resetActivity();
        return;
      }
    }

    // Determine the next question using the choice's "next" pointer.
    int? nextIndex = currentQuestion.choices[choiceIndex].next;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (nextIndex != null && nextIndex < level.questions.length) {
        // Trigger a breathing minigame only once per level.
        if (!_minigamePlayed && nextIndex == 2) {
          // Randomly choose one minigame from the available options.
          final List<Widget> minigameWidgets = [
            const BreathingMinigame(),
            const RippleMinigame(),
          ];
          final random = Random();
          final chosenMinigame =
              minigameWidgets[random.nextInt(minigameWidgets.length)];
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FadeTransition(
                opacity: animation,
                child: chosenMinigame,
              ),
              reverseTransitionDuration: const Duration(milliseconds: 800),
            ),
          ).then((value) {
            setState(() {
              _minigamePlayed = true;
              _concentration = _targetConcentration;
              _currentQuestionIndex = nextIndex;
              _textController.reset();
              _textController.forward();
            });
          });
        } else {
          setState(() {
            _concentration = _targetConcentration;
            _currentQuestionIndex = nextIndex;
            _textController.reset();
            _textController.forward();
          });
        }
      } else {
        setState(() {
          _currentStage = MazeStage.reflection;
        });
      }
    });
  }

  /// Builds the introduction stage with the theme blurb and key pointers.
  Widget _buildIntroduction() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              (AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  level.themeBlurb,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ...level.keyPointers.map(
                  (pointer) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Text(
                      "• $pointer",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
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
                  onPressed: _startAdventure,
                  child: const Text("Start Adventure"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the interactive question stage.
  Widget _buildQuestion() {
    final currentQuestion = level.questions[_currentQuestionIndex];
    double screenHeight = MediaQuery.of(context).size.height -
        (AppBar().preferredSize.height + MediaQuery.of(context).padding.top);

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: screenHeight),
        child: Column(
          children: [
            // Top graphic area (40% of screen height) with an animated cool-spectrum gradient.
            AnimatedBuilder(
              animation: _topGradientController,
              builder: (context, child) {
                double hue = 180 + (_topGradientController.value * 120);
                Color color1 = HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
                Color color2 =
                    HSLColor.fromAHSL(1.0, (hue + 60) % 360, 0.7, 0.5)
                        .toColor();
                return Container(
                  height: screenHeight * 0.4,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color1, color2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: AnimatedAlign(
                    alignment: _getMazeAlignment(),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeInOut,
                    child: const Icon(
                      Icons.directions_run,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            // Bottom area: question text, choices, and health bar.
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _textFadeAnimation,
                    child: Text(
                      currentQuestion.text,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...List.generate(currentQuestion.choices.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          foregroundColor: Colors.teal,
                        ),
                        onPressed: () => _handleAnswer(index),
                        child: Text(currentQuestion.choices[index].text),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: _healthAnimation.value,
                    backgroundColor: Colors.white.withOpacity(0.5),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Concentration: ${(_healthAnimation.value * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the final reflection stage using a custom animated widget.
  Widget _buildReflection() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height -
              (AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ReflectionContent(
              reflection: level.reflection,
              onFinish: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_currentStage) {
      case MazeStage.introduction:
        content = _buildIntroduction();
        break;
      case MazeStage.questions:
        content = _buildQuestion();
        break;
      case MazeStage.reflection:
        content = _buildReflection();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mellow Maze Adventure"),
        backgroundColor: Colors.teal[800],
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _backgroundAnimation.value ?? Colors.teal,
                  Colors.teal.shade900,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// ReflectionContent displays the final reflection using a slide‐and‐fade animation
/// along with a rotating icon for added visual impact.
class ReflectionContent extends StatefulWidget {
  final String reflection;
  final VoidCallback onFinish;
  const ReflectionContent(
      {required this.reflection, required this.onFinish, super.key});

  @override
  _ReflectionContentState createState() => _ReflectionContentState();
}

class _ReflectionContentState extends State<ReflectionContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(parent: _controller, curve: Curves.linear),
              ),
              child: const Icon(Icons.spa, size: 48, color: Colors.tealAccent),
            ),
            const SizedBox(height: 20),
            Text(
              widget.reflection,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
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
              onPressed: widget.onFinish,
              child: const Text("Finish"),
            ),
          ],
        ),
      ),
    );
  }
}
