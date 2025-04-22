// mellowmazemini.dart
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
    // Animation controller cycles every 4 seconds.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _controller.repeat();
    // Automatically finish after 10 seconds.
    _timer = Timer(const Duration(seconds: 10), () {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  // Builds one animated ring with a given delay.
  Widget _buildRing(double delay) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Offset the animation value to create staggered rings.
        double progress = (_controller.value + delay) % 1.0;
        double scale = 0.5 + progress; // Scale from 0.5 to 1.5
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
      // Teal-based gradient background.
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
/// Uses a custom painter to draw expanding, fading ripple circles.
/// ------------------
class RippleMinigame extends StatefulWidget {
  const RippleMinigame({super.key});

  @override
  _RippleMinigameState createState() => _RippleMinigameState();
}

class _RippleMinigameState extends State<RippleMinigame>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Animation controller cycles every 3 seconds.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _controller.repeat();
    // Automatically finish after 10 seconds.
    _timer = Timer(const Duration(seconds: 10), () {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Teal-based gradient background.
      backgroundColor: Colors.teal.shade900,
      body: Center(
        child: CustomPaint(
          painter: RipplePainter(animation: _controller),
          child: const SizedBox(width: 200, height: 200),
        ),
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final Animation<double> animation;

  RipplePainter({required this.animation}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    double progress = animation.value;
    double maxRadius = size.width / 2;
    // Draw three concentric ripple circles.
    for (int i = 0; i < 3; i++) {
      double offset = i / 3.0;
      double radius = maxRadius * ((progress + offset) % 1.0);
      double opacity = 1.0 - ((progress + offset) % 1.0);
      paint.color = Colors.tealAccent.withOpacity(opacity);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RipplePainter oldDelegate) => true;
}
