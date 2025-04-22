import 'package:flutter/material.dart';
import 'dart:async';
import '../../../storage.dart';
import 'journal_prompt_screen.dart';
import 'mood_trends_screen.dart';

class JournalListScreen extends StatefulWidget {

  const JournalListScreen({super.key});

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
    try {
      final entries = await Storage.storage.getAllMoodJournalEntries();
      setState(() {
        journalEntries = entries;
      });
    } catch (e) {
      print('Error loading journal entries: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Entries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalPromptScreen(
                    mood: {'label': 'Happy'}, // Example mood
                    intensity: 3.0, // Example intensity
                  ),
                ),
              ).then((_) => loadJournalEntries());
            },
          ),
          IconButton(
              icon: const Text('Show Mood Trends'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MoodTrendsScreen(storage: Storage.storage)),
                );
              }),
        ],
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
