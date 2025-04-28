<<<<<<< HEAD
import 'package:calm_quest/notifications.dart';
import 'package:calm_quest/storage.dart';
import 'achievements_system.dart';
import 'package:flutter/material.dart';
import 'breathing_activity.dart';
import 'achievements_screen.dart';
import 'settings_screen.dart';
import 'screens/todays_activities.dart';
import 'TranquilForestlandingpage.dart'; // Correct file name
import 'serene_beach_page.dart';
import 'placeholder_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(const CalmQuestApp());
  initializeSystems();
}

void initializeSystems() async{
  notifications.init();
  await Storage.create();
  await AchievementsSystem.init();
  AchievementsSystem.updateAchievementCondition(Achievement.Welcome_to_the_Cove, 1);
=======
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calm_quest/theme_notifier.dart';
import 'package:calm_quest/notifications.dart';
import 'package:calm_quest/storage.dart';
import 'package:calm_quest/achievements_system.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'screens/todays_activities.dart';
import 'achievements_screen.dart';
import 'breathing_activity.dart';
import 'placeholder_screen.dart';
import 'serene_beach_page.dart';
import 'TranquilForestlandingpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Await initialization before runApp
  await notifications.init();
  await Storage.create();
  await AchievementsSystem.init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const CalmQuestApp(),
    ),
  );
>>>>>>> local-version
}

class CalmQuestApp extends StatelessWidget {
  const CalmQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calm Quest App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
=======
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CalmQuest',
      themeMode: themeNotifier.themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFE0F7FA),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF141E30),
>>>>>>> local-version
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
<<<<<<< HEAD
        '/todays_activities': (context)=> const TodaysActivitiesScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/breathing_activity': (context) => const BreathingActivity(),
        '/tranquil_forest': (context) => TranquilForestLandingPage(), // Correct reference
        '/serene_beach': (context) =>  SereneBeachPage(),
        '/placeholder': (context) => const PlaceholderScreen(
              message: 'Feature Under Construction',
            ),
      },
    );
  }
}
=======
        '/settings': (context) => const SettingsScreen(),
        '/todays_activities': (context) => const TodaysActivitiesScreen(),
        '/achievements': (context) => const AchievementsScreen(),
        '/breathing_activity': (context) => const BreathingActivity(),
        '/tranquil_forest': (context) => TranquilForestLandingPage(),
        '/serene_beach': (context) => SereneBeachPage(),
        '/placeholder': (context) => const PlaceholderScreen(message: 'Feature Under Construction'),
      },
    );
  }
}



>>>>>>> local-version
