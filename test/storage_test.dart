import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart'; // For path handling
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // For desktop testing using SQLite FFI
import './storage.dart'; // Import your Storage class

void main() {
  setUpAll(() {
    sqfliteFfiInit(); // Initialize FFI for database
    databaseFactory =
        databaseFactoryFfi; // Set the database factory to the FFI factory
  });

  // Test for creation and closing of the database
  test('CREATION AND CLOSE TEST', () async {
    // Specify the path for the test database
    String dbPath = join(await getDatabasesPath(), 'test_storage.db');

    // Create the Storage instance
    Storage storage = await Storage.create(dbName: dbPath);

    // Ensure the Storage instance is not null
    expect(storage, isNotNull);

    // Check if the correct database path is being used
    expect(dbPath.contains('test_storage.db'), true);

    // Close the database
    storage.close();
  });

  // Test for inserting and retrieving activity logs
  test('ACTIVITY LOG TEST', () async {
    String dbPath = join(await getDatabasesPath(), 'test_storage.db');
    Storage storage = await Storage.create(dbName: dbPath);

    // Insert a new activity log
    await storage.insertActivityLog(
        ActivityName.breathe, DateTime.now().toIso8601String());

    // Retrieve the activity logs
    var logs = await storage.getActivityLogs([ActivityName.breathe]);
    expect(logs.isNotEmpty, true);

    // Print activity logs table
    await printActivityLogsTable(storage);

    storage.close();
  });

  // Test for inserting and retrieving preferences
  test('PREFERENCES TEST', () async {
    String dbPath = join(await getDatabasesPath(), 'test_storage.db');
    Storage storage = await Storage.create(dbName: dbPath);

    // Insert or update a preference
    await storage.setPreference(PreferenceName.dailyReminder, true);

    // Retrieve preferences
    var preferences =
        await storage.getPreferences([PreferenceName.dailyReminder]);
    expect(preferences?[PreferenceName.dailyReminder], true);

    // Print preferences table
    await printPreferencesTable(storage);

    storage.close();
  });

  // Test for retrieving achievements
  test('ACHIEVEMENTS TEST', () async {
    String dbPath = join(await getDatabasesPath(), 'test_storage.db');
    Storage storage = await Storage.create(dbName: dbPath);

    // Insert an achievement (if your storage allows this)
    await storage.insertAchievement(
        Achievement.breathingExercise, DateTime.now());

    // Retrieve achievements
    var achievements = await storage
        .getAchievementsCompletionDate([Achievement.breathingExercise]);
    expect(achievements.isNotEmpty, true);

    // Print achievements table
    await printAchievementsTable(storage);

    storage.close();
  });
}

/// Prints the activities table using the existing method
Future<void> printActivitiesTable(Storage storage) async {
  var activityLogs =
      await storage.getActivityLogs([ActivityName.breathe, ActivityName.all]);
  print('Activities Table:');
  activityLogs.forEach((activity, details) {
    print('$activity -> $details');
  });
}

/// Prints the activity logs table
Future<void> printActivityLogsTable(Storage storage) async {
  var activityLogs = await storage.getActivityLogs([ActivityName.breathe]);
  print('Activity Logs Table:');
  activityLogs.forEach((activity, details) {
    print('$activity -> $details');
  });
}

/// Prints the preferences table
Future<void> printPreferencesTable(Storage storage) async {
  var preferences = await storage.getPreferences([PreferenceName.all]);
  print('Preferences Table:');
  preferences?.forEach((preference, value) {
    print('$preference -> $value');
  });
}

/// Prints the achievements table
Future<void> printAchievementsTable(Storage storage) async {
  var achievements =
      await storage.getAchievementsCompletionDate([Achievement.all]);
  print('Achievements Table:');
  achievements.forEach((achievement, date) {
    print('$achievement -> $date');
  });
}
