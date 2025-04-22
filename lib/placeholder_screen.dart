import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String message;

  const PlaceholderScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CalmQuest Placeholder'),
      ),
      body: Center(
        child: Text(
          message,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
