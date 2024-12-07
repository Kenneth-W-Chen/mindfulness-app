import 'package:flutter/material.dart';

class TwilightAlleyLoad extends StatefulWidget {
  const TwilightAlleyLoad({Key? key}) : super(key: key);

  @override
  _TwilightAlleyLoadState createState() => _TwilightAlleyLoadState();
}

class _TwilightAlleyLoadState extends State<TwilightAlleyLoad> with SingleTickerProviderStateMixin {
  late AnimationController _textController;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _textController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _textOpacity = Tween<double>(begin: 0.5, end: 1.0).animate(_textController);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Twilight Alley',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.deepPurple[800],
        elevation: 0,
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
        child: Stack(
          children: [
            Positioned(
              top: 100,
              left: 50,
              right: 50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.star, color: Colors.white, size: 30),
                  Icon(Icons.star, color: Colors.white, size: 24),
                  Icon(Icons.nightlight_round, color: Colors.white, size: 60),
                  Icon(Icons.star, color: Colors.white, size: 24),
                  Icon(Icons.star, color: Colors.white, size: 30),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 8.0, // Increased stroke width for a bolder look
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _textOpacity,
                    child: const Text(
                      'Loading, please wait...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24, // Increased font size for better visibility
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  Icon(Icons.star, color: Colors.white, size: 20),
                  Icon(Icons.nightlight_round, color: Colors.white, size: 50),
                  Icon(Icons.star, color: Colors.white, size: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
