import'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Custom_Bottom_Navigation_Bar.dart';
import 'storage.dart';


class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  _AchievementsScreenState createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<Achievement, DateTime?> achievements = {};
  final DateFormat formatter = DateFormat.yMMMd('en-US');

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
       achievements = await Storage.storage.getAchievementsCompletionDate([Achievement.all]);

      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Achievements loaded.', style: TextStyle(color: Colors.black)),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              width: 280,
              padding: const EdgeInsets.only(left: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              showCloseIcon: true,
              closeIconColor: Colors.black38,
            )
        );
      });
    } catch (e) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to load achievements.', style: TextStyle(color: Colors.black)),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.white,
              behavior: SnackBarBehavior.floating,
              width: 280,
              padding: const EdgeInsets.only(left: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              showCloseIcon: true,
              closeIconColor: Colors.black38,
            )
        );
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
          Expanded(
            child: achievements.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      children: Achievement.values.where((a)=> a.value > -1).map((Achievement a) {
                        return _buildAchievementCard(a, achievements[a]);
                      }).toList(growable: false),
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
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/todays_activities');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(
                context, '/settings'); // Navigate to Settings
          }
        },
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, DateTime? completionDate) {
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
            completionDate != null ? const Icon(Icons.star, size: 48, color: Colors.amber) : Stack(children: [Icon(Icons.star, size:48, color:Colors.grey[300]), Icon(Icons.star_border, size:48, color: Colors.grey[400]),]),
            const SizedBox(height: 10),
            Text(
              achievement.name.replaceAll('_', ' '),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              achievement.description,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400,color: Color(0xff434343)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              completionDate != null ? "Completed on ${formatter.format(completionDate)}":'Not completed',
              style: const TextStyle(fontSize: 10, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
