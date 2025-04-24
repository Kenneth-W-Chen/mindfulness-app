import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'twilight_alley_intro.dart';
import '../../storage.dart';
import 'package:dart_sentiment/dart_sentiment.dart';
import 'twilight_alley_AI.dart';

class TwilightAlleyActivity extends StatefulWidget {
  const TwilightAlleyActivity({Key? key}) : super(key: key);

  @override
  _TwilightAlleyActivityState createState() => _TwilightAlleyActivityState();
}

class _TwilightAlleyActivityState extends State<TwilightAlleyActivity>
    with TickerProviderStateMixin {
  // ────────────────────── Animation ──────────────────────
  late final AnimationController _fadeController;
  late final AnimationController _leftStarController;
  late final AnimationController _rightStarController;
  late final Animation<double> _fadeAnimation;

  // ────────────────────── State ──────────────────────
  bool _activityCompleted = false;
  final List<String> _prompts = const [
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

  final List<String> _emojiPrompts = const [
    "How satisfied are you with your day?",
    "How do you feel about your progress this week?",
    "Are you happy with your accomplishments today?",
    "Do you feel motivated for tomorrow?",
    "How connected do you feel to your goals?"
  ];
  int _currentEmojiPromptIndex = 0;
  final List<String> _emojiResponses = [];
  String _gptRecommendation = '';
  int    _gptScore          = 5;
  int _totalEmojiPoints = 0;
  bool _sadEmojiSelected = false;
  int _emotionalVolatilityScore = 0;
  final Map<String, int> _emojiPoints = const {
    "happy": 3,
    "neutral": 2,
    "sad": 1,
  };

  final Sentiment _sentiment = Sentiment();

  // ────────────────────── AI Helper ──────────────────────
  TwilightAlleyAI? _ai;
  bool _aiReady = false;

  @override
  void initState() {
    super.initState();

    // Animations
    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
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

    // Load the AI client
    TwilightAlleyAI.create().then((ai) {
      setState(() {
        _ai = ai;
        _aiReady = true;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _leftStarController.dispose();
    _rightStarController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // ────────────────────── Helper ──────────────────────
  Future<void> _showAdvice(String advice) async {
    // Split GPT text into sentences.
    final sentences = advice
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((s) => s.trim().isNotEmpty)
        .toList();

    // Await so the function still returns Future<void>
    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Advice',
      barrierColor: Colors.black54,                       // dim background
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondary) {
        return Center(
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
            ),
            child: _AdviceCard(sentences: sentences),
          ),
        );
      },
    );
  }

  // ────────────────────── Flow control ──────────────────────
  Future<void> _getNextPrompt() async {
    if (_currentPromptIndex < _prompts.length) {
      // Next text prompt
      setState(() => _isPromptVisible = false);
      await Future.delayed(const Duration(milliseconds: 500));
      _textController.clear();
      setState(() {
        _currentPromptIndex++;
        _isPromptVisible = true;
      });
    } else if (_currentEmojiPromptIndex < _emojiPrompts.length) {
      // Next emoji prompt
      setState(() => _isPromptVisible = false);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isPromptVisible = true);
    } else {
      // Finished – store log & go to summary
      _activityCompleted = true;
      final storage = await Storage.create();
      final pointsMessage = _totalEmojiPoints < 13
          ? 'Total Emoji Points: $_totalEmojiPoints (Less than 13)'
          : 'Total Emoji Points: $_totalEmojiPoints';

      final future = storage.addActivityLog(
        ActivityName.twilight_alley,
        [
          ..._userResponses,
          ..._emojiResponses,
          pointsMessage,
          'Sad Emoji Selected: ${_sadEmojiSelected ? 'Yes' : 'No'}',
          'Emotional Volatility Score: $_emotionalVolatilityScore',
        ].join('\n'),
      );

      // ──  NEW: call GPT for end-of-session recommendation  ──
      try {
        final (rec, sc) = await _ai!.getSessionSummary(
          combinedLog: [
            ..._userResponses,
            ..._emojiResponses,
            pointsMessage,
            'Emotional Volatility Score: $_emotionalVolatilityScore',
          ].join('\n'),
        );
        _gptRecommendation = rec;
        _gptScore = sc;
      } catch (e) {
        debugPrint('GPT summary error: $e');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionSummaryScreen(
            userResponses: _userResponses,
            emojiResponses: _emojiResponses,
            recommendation: _gptRecommendation,
            wellnessScore: _gptScore,
            pointsMessage: pointsMessage,
            sadEmojiSelected: _sadEmojiSelected,
            emotionalVolatilityScore: _emotionalVolatilityScore,
          ),
        ),
      );
      await future;
    }
  }

  void _handleEmojiResponse(String response) {
    setState(() {
      _emojiResponses.add(response);
      _totalEmojiPoints += _emojiPoints[response]!;
      if (response == 'sad') _sadEmojiSelected = true;
      if (_currentEmojiPromptIndex < _emojiPrompts.length - 1) {
        _isPromptVisible = false;
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _currentEmojiPromptIndex++;
            _isPromptVisible = true;
          });
        });
      } else {
        _currentEmojiPromptIndex++;
        _activityCompleted = true;
        _getNextPrompt();
      }
    });
  }

  // ────────────────────── UI ──────────────────────
  Widget _buildSentimentGauge() => AnimatedDefaultTextStyle(
    duration: const Duration(milliseconds: 500),
    style: const TextStyle(
        fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.bold),
    child:
    Text('Emotional Volatility Score: $_emotionalVolatilityScore'),
  );

  Widget _buildSentimentBar(BuildContext context) {
    const maxScore = 20.0;
    final totalWidth = MediaQuery.of(context).size.width - 40;
    final fillWidth =
        totalWidth * (_emotionalVolatilityScore.clamp(0, maxScore) / maxScore);

    return Column(
      children: [
        Container(
          width: totalWidth,
          height: 10,
          color: Colors.grey[300],
          child: Stack(children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: fillWidth,
              height: 10,
              color: Colors.blueAccent,
            ),
          ]),
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
        'Twilight Alley',
        Colors.deepPurple[800]!,
        context,
        _activityCompleted,
      ),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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

  // ────────────────────── Text Prompt Widget ──────────────────────
  Widget _buildTextPrompt() {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: RotationTransition(
              turns: _leftStarController,
              child: const Icon(Icons.star, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 20),
          const Icon(Icons.nightlight_round, color: Colors.white, size: 80),
          const SizedBox(width: 20),
          FadeTransition(
            opacity: _fadeAnimation,
            child: RotationTransition(
              turns: _rightStarController,
              child: const Icon(Icons.star, color: Colors.white, size: 24),
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
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
        onPressed: _aiReady
            ? () async {
          if (_textController.text.isEmpty) return;

          final userText = _textController.text;

          // Sentiment → volatility score
          final result = _sentiment.analysis(userText, emoji: true);
          setState(() {
            _emotionalVolatilityScore +=
                (result['score'] as int).abs();
          });
          _userResponses.add(userText);

          // Fetch AI advice (≤4 sentences) and display
          try {
            final advice = await _ai!.getAdvice(
              prompt: _prompts[_currentPromptIndex],
              user: userText,
            );
            await _showAdvice(advice);
          } catch (e) {
            debugPrint('AI error: $e');
          }

          _getNextPrompt();
        }
            : null,
        child: const Text('Submit'),
      ),
    ]);
  }

  // ────────────────────── Emoji Prompt Widget ──────────────────────
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
                  onPressed: () => _handleEmojiResponse('happy')),
              IconButton(
                  icon: const Icon(Icons.sentiment_neutral,
                      size: 60, color: Colors.yellow),
                  onPressed: () => _handleEmojiResponse('neutral')),
              IconButton(
                  icon: const Icon(Icons.sentiment_dissatisfied,
                      size: 60, color: Colors.red),
                  onPressed: () => _handleEmojiResponse('sad')),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Session Summary ─────────────────────────
class SessionSummaryScreen extends StatelessWidget {
  final List<String> userResponses;
  final List<String> emojiResponses;
  final String pointsMessage;
  final bool sadEmojiSelected;
  final int emotionalVolatilityScore;
  final String recommendation;
  final int    wellnessScore;

  const SessionSummaryScreen({
    Key? key,
    required this.userResponses,
    required this.emojiResponses,
    required this.pointsMessage,
    required this.sadEmojiSelected,
    required this.emotionalVolatilityScore,
    required this.recommendation,
    required this.wellnessScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    const Text('Session Summary',
    style: TextStyle(
    fontSize: 28,
    color: Colors.white,
    fontWeight: FontWeight.bold)),
    const SizedBox(height: 20),
    Text('Emotional Volatility Score: $emotionalVolatilityScore',
    style: const TextStyle(
    fontSize: 20,
    color: Colors.blueAccent,
    fontWeight: FontWeight.bold)),
    const SizedBox(height: 10),
    Text(pointsMessage,
    style: const TextStyle(fontSize: 18, color: Colors.white),
    textAlign: TextAlign.center),
    const SizedBox(height: 10),
    Text('Sad Emoji Selected: ${sadEmojiSelected ? 'Yes' : 'No'}',
    style: const TextStyle(fontSize: 18, color: Colors.white),
    textAlign: TextAlign.center),
    const Divider(color: Colors.white54, height: 40),
      Text(
        'Well-being Score (1-10): $wellnessScore',
        style: const TextStyle(
          fontSize: 20,
          color: Colors.cyanAccent,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      Text(
        'GPT Recommendation:\n$recommendation',
        style: const TextStyle(fontSize: 18, color: Colors.white),
        textAlign: TextAlign.center,
      ),
      const Divider(color: Colors.white54, height: 40),


    const Align(
    alignment: Alignment.centerLeft,
    child: Text('Text Responses:',
    style: TextStyle(
    fontSize: 20,
    color: Colors.white70,
    fontWeight: FontWeight.bold)),
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
          backgroundColor: Colors.blueAccent,
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
// ───────────────────────── Advice Popup Card ─────────────────────────
// ───────────────────────── Advice Popup Card ─────────────────────────
// ───────────────────────── Advice Popup Card ─────────────────────────
class _AdviceCard extends StatefulWidget {
  final List<String> sentences;
  const _AdviceCard({Key? key, required this.sentences}) : super(key: key);

  @override
  State<_AdviceCard> createState() => _AdviceCardState();
}

class _AdviceCardState extends State<_AdviceCard> with TickerProviderStateMixin {
  late final List<AnimationController> _ctrl;
  late final List<Animation<double>> _fade;
  late final List<Animation<Offset>> _slide;

  @override
  void initState() {
    super.initState();

    // one controller per sentence
    _ctrl = List.generate(
      widget.sentences.length,
          (_) => AnimationController(
        duration: const Duration(milliseconds: 500), // slower fade-in
        vsync: this,
      ),
    );

    _fade  = _ctrl.map((c) =>
        CurvedAnimation(parent: c, curve: Curves.easeIn)).toList();

    _slide = _ctrl.map((c) =>
        Tween(begin: const Offset(0, .20), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut))).toList();

    _revealSequentially();
  }

  Future<void> _revealSequentially() async {
    for (final c in _ctrl) {
      c.forward();
      await Future.delayed(const Duration(milliseconds: 1100)); // slower gap
    }
  }

  @override
  void dispose() {
    for (final c in _ctrl) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2196F3), Color(0xFF3F51B5), Color(0xFF673AB7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.sentences.length, _buildSentenceBox),
        ),
      ),
    );
  }

  /// Builds one little rounded sub-card per sentence.
  Widget _buildSentenceBox(int i) => FadeTransition(
    opacity: _fade[i],
    child: SlideTransition(
      position: _slide[i],
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          widget.sentences[i],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ),
    ),
  );
}
