import 'package:calm_quest/screens/shared/activity_app_bar.dart';
import 'package:flutter/material.dart';
import '../../../storage.dart';
import 'journal_prompt_screen.dart';

class MoodSelectionScreen extends StatefulWidget {

  const MoodSelectionScreen({super.key});

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
      appBar: activityAppBar('Select Your Mood', Colors.white, context, false,
          backButtonColor: null),
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
