import 'dart:async';
import 'package:flutter/material.dart';

/// ------------------
/// BreathingMinigame
/// Uses concentric rings with a ripple effect.
/// ------------------
class BreathingMinigame extends StatefulWidget {
  const BreathingMinigame({super.key});

  @override
  _BreathingMinigameState createState() => _BreathingMinigameState();
}

class _BreathingMinigameState extends State<BreathingMinigame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    // Automatically finish after 10 seconds if user doesn't interact.
    _timer = Timer(const Duration(seconds: 10), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  Widget _buildRing(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double progress = (_controller.value + delay) % 1.0;
        double scale = 0.5 + progress;
        double opacity = (1 - progress).clamp(0.0, 1.0);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.tealAccent.withOpacity(opacity),
                width: 4,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade900,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildRing(0.0),
            _buildRing(0.33),
            _buildRing(0.66),
          ],
        ),
      ),
    );
  }
}

/// ------------------
/// RippleMinigame
/// Intro ripple effect followed by a 6-question emotion quiz with a fade transition.
/// ------------------
class RippleMinigame extends StatefulWidget {
  const RippleMinigame({super.key});

  @override
  _RippleMinigameState createState() => _RippleMinigameState();
}

class _RippleMinigameState extends State<RippleMinigame>
    with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Timer _introTimer;
  bool _showQuiz = false;

  int _currentQuestion = 0;
  int _score = 0;

  final List<EmotionQuestion> _questions = [
    EmotionQuestion(
      'When faced with a challenge, you usually feel:',
      [
        QuizChoice('Excited', 2),
        QuizChoice('Nervous', 1),
        QuizChoice('Overwhelmed', 0),
      ],
    ),
    EmotionQuestion(
      'On a relaxing day, you tend to:',
      [
        QuizChoice('Plan ahead', 1),
        QuizChoice('Go with the flow', 2),
        QuizChoice('Keep checking tasks', 0),
      ],
    ),
    EmotionQuestion(
      'When thinking about the future, you feel:',
      [
        QuizChoice('Hopeful', 2),
        QuizChoice('Anxious', 1),
        QuizChoice('Indifferent', 0),
      ],
    ),
    EmotionQuestion(
      'In a group, you usually:',
      [
        QuizChoice('Lead', 2),
        QuizChoice('Support quietly', 1),
        QuizChoice('Stay on edge', 0),
      ],
    ),
    EmotionQuestion(
      'Your favorite music makes you feel:',
      [
        QuizChoice('Uplifted', 2),
        QuizChoice('Calm', 1),
        QuizChoice('Restless', 0),
      ],
    ),
    EmotionQuestion(
      'At day’s end, you’re more:',
      [
        QuizChoice('Satisfied', 2),
        QuizChoice('Tired but OK', 1),
        QuizChoice('Stressed', 0),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _introTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showQuiz = true;
      });
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _introTimer.cancel();
    super.dispose();
  }

  void _answer(int pts) {
    _score += pts;
    if (_currentQuestion < _questions.length - 1) {
      setState(() => _currentQuestion++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmotionResult(score: _score),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      child: !_showQuiz
          ? _buildRippleIntro()
          : _buildQuizScreen(),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }

  Widget _buildRippleIntro() {
    return Scaffold(
      key: const ValueKey('ripple'),
      backgroundColor: Colors.teal.shade900,
      body: Center(
        child: CustomPaint(
          painter: _RipplePainter(animation: _rippleController),
          child: const SizedBox(width: 200, height: 200),
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    final q = _questions[_currentQuestion];
    return Scaffold(
      key: const ValueKey('quiz'),
      backgroundColor: Colors.teal.shade900,
      appBar: AppBar(
        title: const Text('Emotion Quiz'),
        backgroundColor: Colors.teal[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              q.text,
              style: const TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ...q.choices.map((c) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.teal[900],
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: () => _answer(c.points),
                child: Text(c.text),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class EmotionQuestion {
  final String text;
  final List<QuizChoice> choices;
  EmotionQuestion(this.text, this.choices);
}

class QuizChoice {
  final String text;
  final int points;
  QuizChoice(this.text, this.points);
}

class EmotionResult extends StatelessWidget {
  final int score;
  const EmotionResult({required this.score, super.key});

  String get emotion {
    if (score <= 4) return 'Anxious';
    if (score <= 8) return 'Calm';
    return 'Joyful';
  }

  IconData get icon {
    switch (emotion) {
      case 'Anxious':
        return Icons.sentiment_dissatisfied;
      case 'Calm':
        return Icons.sentiment_neutral;
      default:
        return Icons.sentiment_very_satisfied;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade900,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 80, color: Colors.tealAccent),
              const SizedBox(height: 16),
              Text(
                'You seem ${emotion}!',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.teal[900],
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final Animation<double> animation;
  _RipplePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    double progress = animation.value;
    double maxRadius = size.width / 2;
    for (int i = 0; i < 3; i++) {
      double offset = i / 3.0;
      double radius = maxRadius * ((progress + offset) % 1.0);
      double opacity = 1.0 - ((progress + offset) % 1.0);
      paint.color = Colors.tealAccent.withOpacity(opacity);
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) => true;
}