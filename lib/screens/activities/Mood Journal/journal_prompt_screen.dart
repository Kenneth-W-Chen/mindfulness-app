import 'package:calm_quest/screens/activities/Mood%20Journal/journal_list_screen.dart';
import 'package:flutter/material.dart';
import '../../../storage.dart';

class JournalPromptScreen extends StatefulWidget {
  final Map<String, String> mood;
  final double intensity;
  final Storage storage; // Added the storage instance

  const JournalPromptScreen({
    super.key,
    required this.mood,
    required this.intensity,
    required this.storage, // Added the storage instance
  });

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
    final date = DateTime.now().toIso8601String();
    await widget.storage.insertMoodJournal(
      date,
      widget.mood['label']!,
      widget.intensity.toInt(),
      _controller.text,
    );
    // Navigate back or to another screen after saving
    Navigator.pop(context);
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
                    MaterialPageRoute(
                        builder: (context) =>
                            JournalListScreen(storage: widget.storage)),
                    result: true);
              },
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }
}
