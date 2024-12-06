import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'journal_list_screen.dart';

class JournalPromptScreen extends StatefulWidget {
  final Map<String, String> mood;
  final double intensity;

  const JournalPromptScreen({Key? key, required this.mood, required this.intensity}) : super(key: key);

  @override
  _JournalPromptScreenState createState() => _JournalPromptScreenState();
}

class _JournalPromptScreenState extends State<JournalPromptScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> prompts = [
    'What made you feel this way?',
    'What are you grateful for?',
    'Anything else you want to share?',
  ];
  String selectedPrompt = '';

  @override
  void initState() {
    super.initState();
    selectedPrompt = prompts[0];
  }

  Future<void> saveEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = prefs.getStringList('mood_entries') ?? [];
    final entry = {
      'date': DateTime.now().toIso8601String(),
      'mood': widget.mood['label'],
      'intensity': widget.intensity,
      'note': _controller.text,
    };
    entries.add(json.encode(entry));
    await prefs.setStringList('mood_entries', entries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mood Journal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              selectedPrompt,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Write your thoughts here...',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedPrompt,
              items: prompts.map((String prompt) {
                return DropdownMenuItem<String>(
                  value: prompt,
                  child: Text(prompt),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPrompt = value!;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () async {
                await saveEntry();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const JournalListScreen()),
                );
              },
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
