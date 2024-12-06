// Updated Flutter code to add a journal list screen to view past entries

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'journal_prompt_screen.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({Key? key}) : super(key: key);

  @override
  _JournalListScreenState createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  List<Map<String, dynamic>> journalEntries = [];

  @override
  void initState() {
    super.initState();
    loadJournalEntries();
  }

  Future<void> loadJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entries = prefs.getStringList('mood_entries') ?? [];
    setState(() {
      journalEntries = entries
          .map((e) => Map<String, dynamic>.from(json.decode(e)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entries'),
      ),
      body: journalEntries.isNotEmpty
          ? ListView.builder(
              itemCount: journalEntries.length,
              itemBuilder: (context, index) {
                final entry = journalEntries[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(entry['mood'] ?? 'No Mood Selected'),
                    subtitle: Text(entry['note'] ?? 'No Note'),
                    trailing: Text(
                      entry['date'] != null
                          ? DateTime.parse(entry['date']).toLocal().toString()
                          : 'No Date',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Journal Entry - ${entry['mood']}'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  'Date: ${DateTime.parse(entry['date']).toLocal()}'),
                              const SizedBox(height: 8.0),
                              Text('Mood Intensity: ${entry['intensity']}'),
                              const SizedBox(height: 8.0),
                              Text('Note: ${entry['note']}'),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text('No journal entries available.'),
            ),
    );
  }
}

void main() {
  runApp(const MoodJournalApp());
}

class MoodJournalApp extends StatelessWidget {
  const MoodJournalApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Journal',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MoodSelectionScreen(),
    );
  }
}

class MoodSelectionScreen extends StatefulWidget {
  const MoodSelectionScreen({Key? key}) : super(key: key);

  @override
  _MoodSelectionScreenState createState() => _MoodSelectionScreenState();
}

class _MoodSelectionScreenState extends State<MoodSelectionScreen> {
  final List<Map<String, String>> moods = [
    {'emoji': '😄', 'label': 'Happy'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😡', 'label': 'Angry'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😃', 'label': 'Excited'},
    {'emoji': '😴', 'label': 'Tired'},
  ];

  int? selectedMoodIndex;
  double moodIntensity = 3.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Your Mood'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const JournalListScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'How are you feeling today?',
            style: TextStyle(fontSize: 24),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: moods.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
              ),
              itemBuilder: (context, index) {
                final mood = moods[index];
                final isSelected = selectedMoodIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMoodIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade100
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        mood['emoji']!,
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Text(
            'Mood Intensity',
            style: TextStyle(fontSize: 18),
          ),
          Slider(
            value: moodIntensity,
            min: 1,
            max: 5,
            divisions: 4,
            label: moodIntensity.round().toString(),
            onChanged: (value) {
              setState(() {
                moodIntensity = value;
              });
            },
          ),
          ElevatedButton(
            onPressed: selectedMoodIndex != null
                ? () {
                    final selectedMood = moods[selectedMoodIndex!];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JournalPromptScreen(
                          mood: selectedMood,
                          intensity: moodIntensity,
                        ),
                      ),
                    );
                  }
                : null,
            child: const Text('Next'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// This will allow you to navigate to the Journal List Screen from the Mood Selection Screen.

