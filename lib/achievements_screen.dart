import 'package:flutter/material.dart';
import 'custom_bottom_navigation_bar.dart';
import 'storage.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  String storageStatusMessage = "Loading achievements...";
  List<Map<String, String>> achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      Storage storage = await Storage.create(); // Initialize storage
      Map<Achievement, DateTime?> achievementsData = await storage.getAchievementsCompletionDate([Achievement.all]);

      List<Map<String, String>> loadedAchievements = achievementsData.entries.map((entry) {
        return {
          'title': entry.key.name,
          'description': entry.value != null ? 'Completed on ${entry.value}' : 'Not completed yet',
        };
      }).toList();

      // Add placeholder achievement
      loadedAchievements.insert(0, {
        'title': 'Calming Shield',
        'description': 'Achieved peace of mind.',
      });

      setState(() {
        achievements = loadedAchievements;
        storageStatusMessage = "Achievements loaded successfully from the database!";
      });
    } catch (e) {
      setState(() {
        storageStatusMessage = "Failed to load achievements from the database.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievement Cove'),
      ),
      body: Column(
        children: [
          // Display the status of the storage operation
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              storageStatusMessage,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: achievements.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: achievements.length,
                      itemBuilder: (context, index) {
                        return _buildAchievementCard(
                          title: achievements[index]['title']!,
                          description: achievements[index]['description']!,
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: 2,
        onItemTapped: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/'); // Navigate to Home
          } else if(index == 1){
            Navigator.pushReplacementNamed(context, '/todays_activities');
          }
          else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/settings'); // Navigate to Settings
          }
        },
      ),
    );
  }

  Widget _buildAchievementCard({required String title, required String description}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star, size: 48, color: Colors.amber),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
