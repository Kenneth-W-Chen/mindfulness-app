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
  // === LAYER ANIMATION CONTROLLERS ===
  late AnimationController _cloud1Ctrl;    // CCM2
  late AnimationController _cloud2Ctrl;    // CCM5
  late AnimationController _mountainMidCtrl;  // CCM3
  late AnimationController _mountainFrontCtrl; // CCM4

  // === ALIGNMENT ANIMATIONS ===
  late Animation<Alignment> _cloud1Align;
  late Animation<Alignment> _cloud2Align;
  late Animation<Alignment> _mountainMidAlign;
  late Animation<Alignment> _mountainFrontAlign;

  // === BREATHING & PROGRESS CONTROLLERS ===
  late AnimationController _breathingController;
  late AnimationController _progressController;
  late AnimationController _ballGradientController;

  // For “Inhale/Hold/Exhale/Hold” steps
  int _currentBreathingIndex = 0;
  // For rotating cosmic phrases
  int _currentPhraseIndex = 0;

  final List<String> _breathingSteps = ["Inhale", "Hold", "Exhale", "Hold"];
  final List<Alignment> _squarePositions = [
    Alignment(0, -1),
    Alignment(1, 0),
    Alignment(0, 1),
    Alignment(-1, 0),
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


  @override
  void initState() {
    super.initState();

    // === 1) Animation controllers for the layers that move ===
    // CCM2 & CCM5 -> Cloud layers move left to right, same direction
    _cloud1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);
    _cloud2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat(reverse: true);

    // CCM3 (mid mountain): subtle side-to-side
    _mountainMidCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    // CCM4 (foreground mountain): bigger side-to-side shift
    _mountainFrontCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);

    // === 2) Define alignment tweens. Negative to positive for same direction
    _cloud1Align = AlignmentTween(
      begin: const Alignment(-0.2, 0),
      end: const Alignment(0.2, 0),
    ).animate(CurvedAnimation(
      parent: _cloud1Ctrl,
      curve: Curves.easeInOut,
    ));

    _cloud2Align = AlignmentTween(
      begin: const Alignment(-0.2, 0),
      end: const Alignment(0.2, 0),
    ).animate(CurvedAnimation(
      parent: _cloud2Ctrl,
      curve: Curves.easeInOut,
    ));

    // ccm3: smaller motion range, so it looks behind ccm4
    _mountainMidAlign = AlignmentTween(
      begin: const Alignment(-0.1, 0),
      end: const Alignment(0.1, 0),
    ).animate(CurvedAnimation(
      parent: _mountainMidCtrl,
      curve: Curves.easeInOut,
    ));

    // ccm4 (front) -> bigger range
    _mountainFrontAlign = AlignmentTween(
      begin: const Alignment(-0.3, 0),
      end: const Alignment(0.3, 0),
    ).animate(CurvedAnimation(
      parent: _mountainFrontCtrl,
      curve: Curves.easeInOut,
    ));

    // === 3) Breathing steps (16s cycle) ===
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
              _currentPhraseIndex = (_currentPhraseIndex + 1) % _calmingPhrases.length;
            }
          });
        }
      })
      ..repeat();

    // === 4) 60s progress controller ===
    _progressController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _progressController.forward().then((_) async {
      await Storage.storage.addActivityLog(ActivityName.calming_cliffs, '');
      Navigator.pop(context, true);
    });

    // === 5) Ball color gradient animation
    _ballGradientController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Clean up
    _cloud1Ctrl.dispose();
    _cloud2Ctrl.dispose();
    _mountainMidCtrl.dispose();
    _mountainFrontCtrl.dispose();
    _breathingController.dispose();
    _progressController.dispose();
    _ballGradientController.dispose();
    super.dispose();
  }

  // The ball's alignment around the square
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

  // == Helper: static layer (no movement) for CCM1 sky (since you don’t want it to move) ==
  Widget buildSkyLayer() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/gamify/CCM1.png"),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.none,
          alignment: Alignment.center,
        ),
      ),
    );
  }

  // == Helper: alignment-based layer for the others ==
  Widget buildAlignLayer(
      Animation<Alignment> align,
      String asset, {
        double opacity = 1.0,
      }) {
    return AnimatedBuilder(
      animation: align,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(asset),
              fit: BoxFit.cover,
              alignment: align.value,
              filterQuality: FilterQuality.none,
            ),
          ),
          child: Container(color: Colors.black.withOpacity(1 - opacity)),
          // above line can darken or lighten if you want, or remove
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Stack(
        children: [
          // 1) CCM1 sky, no movement
          buildSkyLayer(),

          // 2) CCM2 (clouds) -> same direction as CCM5
          buildAlignLayer(_cloud1Align, "assets/gamify/CCM2.png", opacity: 0.9),

          // 3) CCM3 (mid mountain)
          buildAlignLayer(_mountainMidAlign, "assets/gamify/CCM3.png", opacity: 0.85),

          // 4) CCM5 (clouds or near-foreground) -> same direction as CCM2
          buildAlignLayer(_cloud2Align, "assets/gamify/CCM5.png", opacity: 0.85),

          // 5) CCM4 (foreground mountain) -> biggest shift
          buildAlignLayer(_mountainFrontAlign, "assets/gamify/CCM4.png", opacity: 0.9),

          // 6) Orange gradient overlay to unify the color scheme
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  // Darker warm orange at top
                  const Color(0xFFFF6D00).withOpacity(0.4),
                  // Lighter orange near bottom
                  const Color(0xFFFFC107).withOpacity(0.2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 7) Main UI with breathing steps, phrases, ball, etc.
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pulsing mountain icon + Timer
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _breathingController,
                      builder: (context, child) {
                        double scale = 1.0 + 0.1 * sin(2 * pi * _breathingController.value);
                        return Transform.scale(
                          scale: scale,
                          child: const Icon(Icons.filter_hdr, size: 48, color: Colors.white),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _progressController,
                      builder: (context, child) {
                        int remainingMillis =
                        (60000 * (1 - _progressController.value)).round();
                        Duration remaining = Duration(milliseconds: remainingMillis);
                        String timeStr =
                            "${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}";
                        return Text(
                          timeStr,
                          style: const TextStyle(color: Colors.white, fontSize: 20),
                        );
                      },
                    ),
                  ],
                ),

                // Middle content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Breathing step
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

                      // Phrase
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

                      // The square with tracing ball
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: AnimatedBuilder(
                          animation: Listenable.merge(
                            [_breathingController, _ballGradientController],
                          ),
                          builder: (context, child) {
                            Alignment ballAlignment =
                            getSquareAlignment(_breathingController.value);
                            double t = _ballGradientController.value;
                            Color startColor = Color.lerp(Colors.yellow, Colors.white, t)!;
                            Color endColor = Color.lerp(Colors.white, Colors.yellow, t)!;

                            return Align(
                              alignment: ballAlignment,
                              child: Container(
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
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom progress bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
