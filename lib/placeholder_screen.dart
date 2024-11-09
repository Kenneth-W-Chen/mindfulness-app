import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String message;

  const PlaceholderScreen({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CalmQuest Placeholder'),
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
