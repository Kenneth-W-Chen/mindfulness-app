//import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../../storage.dart';

void main() {
  runApp(const QuoteApp());
}

class QuoteApp extends StatelessWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Positive Power-Ups',
      home: QuoteScreen(),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  final List<String> quotes = [
    "I am loved and appreciated.",
    "I am brave and strong.",
    "I can do anything I set my mind to.",
    "I am unique and special.",
    "I am kind and honest.",
    "I am a good friend.",
    "I am worthy of happiness.",
    "I have many talents and abilities.",
    "I am smart and capable.",
    "I choose to be happy and have fun.",
    "I am loved just the way I am.",
    "I am proud of who I am.",
    "I can handle challenges with courage and determination.",
    "I am full of creativity and imagination.",
    "I can learn anything I want to learn.",
    "I have the power to make a difference in the world.",
    "I am confident and self-assured.",
    "I am appreciated for being me.",
    "I am grateful for my friends and family.",
    "I am surrounded by love and support.",
    "I am going to make today count.",
    "I am positive and optimistic.",
    "I am a good listener and helper.",
    "I can handle challenges.",
    "I always do my best.",
    "I am always improving and growing.",
    "I am a good role model for others.",
    "I know it’s ok to make mistakes.",
    "I have the power to control my thoughts and emotions.",
    "I am a positive influence on those around me.",
    "I am a great friend and make others feel loved and valued.",
  ];

  String currentQuote =
      "Feeling overwhelmed? Tap to explore some positive affirmations to ground yourself.";

  late final Timer _completionTimer;
  bool _activityCompleted = false;

  @override
  void initState(){
    super.initState();
    _completionTimer = Timer(const Duration(seconds: 30), () async {
      _activityCompleted = true;
      setState(() {});
      Storage.storage.addActivityLog(ActivityName.positive_affirmations, '');
    });
  }

  @override
  void dispose(){
    _completionTimer.cancel();
    super.dispose();
  }

  void refreshQuote() {
    setState(() {
      currentQuote = quotes[(quotes.length *
              (DateTime.now().millisecondsSinceEpoch % 1000) ~/
              1000) %
          quotes.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Positive Power-Ups'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _activityCompleted); // Navigate back to the previous screen
          },
        ),
        backgroundColor:
            const Color.fromARGB(255, 98, 28, 111), // Solid color for AppBar
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 98, 28, 111),
              Color.fromARGB(255, 134, 42, 35)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '"$currentQuote"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: refreshQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0x00682861),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Reveal an affirmation',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
