import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart'; // Import path for file path handling in tests
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi for desktop testing
import 'package:calm_quest/storage.dart'; // Import your storage class to test its functionality

void main() {
  //Desktop setup
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Delete the test database before each test
    String dbPath = join(await getDatabasesPath(), 'test_storage.db');
    await deleteDatabase(dbPath);
  });

  //Creation operation and close operation
  test('BLACKBOX TEST 1: CREATION AND CLOSE TEST', () async {
    String dbPath = join(await getDatabasesPath(), 'test_storage.db');

    await Storage.create(dbName: dbPath);

    expect(Storage.storage, isNotNull);

    expect(dbPath.contains('test_storage.db'), true);

    Storage.storage.close();
  });

// Test 2: Create two entries in each table, print the contents, delete the entries, and print again
  test('BLACKBOX TEST 2: Create, Print, Delete, Print', () async {
    String dbPath = join(await getDatabasesPath(), 'test_storage.db');
    await Storage.create(dbName: dbPath);

    // Add two logs to the activity_logs table
    Storage.storage.addActivityLog(ActivityName.breathe, "First breathe activity");
    Storage.storage.addActivityLog(ActivityName.breathe, "Second breathe activity");

    // Add two entries to the preferences table
    Storage.storage.updatePreferences(
        {PreferenceName.master_volume: 50, PreferenceName.music_volume: 70});

    // Mark two achievements as completed
    Storage.storage.setAchievementCompleted(Achievement.all);

    // Print all tables after creating the entries
    print('--- After adding two entries ---');
    await printActivitiesTable(Storage.storage);
    await printActivityLogsTable(Storage.storage);
    await printPreferencesTable(Storage.storage);
    await printAchievementsTable(Storage.storage);

    // Delete the two entries from the activity logs and preferences tables
    await Storage.storage.deleteActivityLog(ActivityName.breathe);
    await Storage.storage.deleteActivityLog(ActivityName.breathe);

    await Storage.storage.deletePreference(PreferenceName.master_volume);
    await Storage.storage.deletePreference(PreferenceName.music_volume);

    await Storage.storage.deleteAchievement(Achievement.all);

    // Print all tables again after deleting the entries
    print('--- After deleting the entries ---');
    await printActivitiesTable(Storage.storage); // No deletion in activities table
    await printActivityLogsTable(Storage.storage);
    await printPreferencesTable(Storage.storage);
    await printAchievementsTable(Storage.storage);

    // Close the storage connection
    Storage.storage.close();
  });

  test('WHITEBOX TEST 3: Database Transaction Rollback Test', () async {
    String dbPath = join(await getDatabasesPath(), 'test_storage.db');
    await Storage.create(dbName: dbPath);

    // Ensure the activity exists in the activities table
    var result = await Storage.storage.testDb.query('activities',
        columns: ['id'],
        where: 'name = ?',
        whereArgs: [ActivityName.breathe.name]);

    if (result.isEmpty) {
      print('No activity found for ${ActivityName.breathe.name}');
      fail('Activity "breathe" should exist in the activities table');
    } else {
      print('Activity found: $result');
      int activityId = result[0]['id'] as int;
      print('Activity ID: $activityId');

      // Start a transaction that should roll back
      try {
        await Storage.storage.testDb.transaction((txn) async {
          // Insert a valid activity log entry
          await txn.insert('activity_logs', {
            'activity_id': activityId,
            'completion_date': DateTime.now().daysSinceEpoch(),
            'info': 'Valid activity log'
          });

          // Insert an entry that violates the CHECK constraint
          await txn.insert('activity_logs', {
            'activity_id': activityId,
            'completion_date': DateTime.now().daysSinceEpoch(),
            'info': 'INVALID_LOG' // This will violate the CHECK constraint
          });

          // We expect the failure to prevent reaching this point
          fail('Expected insert failure did not occur');
        }, exclusive: true);
      } catch (e) {
        print('Caught expected failure: $e');
        // Error is expected, continue with test
      }

      // Check that no entries were committed (rolled back)
      var logs = await Storage.storage.getActivityLogs([ActivityName.breathe]);
      expect(logs[ActivityName.breathe]![0]['completion_date'], isNull,
          reason: "Expected no logs due to transaction rollback");
    }

    Storage.storage.close();
  });

  test('WHITEBOX TEST 4: Validate Activity Logs JOIN', () async {
    String dbPath = join(await getDatabasesPath(), 'test_storage.db');
    await Storage.create(dbName: dbPath);

    // Insert test data and await the operation
    await Storage.storage.addActivityLog(ActivityName.breathe, "Test breathe activity");

    // Directly execute the query you want to validate
    var result = await Storage.storage.testDb.rawQuery(
        'SELECT activities.name, activity_logs.completion_date FROM activities '
        'INNER JOIN activity_logs ON activities.id = activity_logs.activity_id '
        'WHERE activities.name = ?',
        [ActivityName.breathe.name]);

    // Expected result for comparison
    expect(result.length, 1,
        reason: "Expected exactly one log entry for 'breathe' activity");
    expect(result[0]['name'], "breathe",
        reason: "Expected 'breathe' activity name in the result");
    expect(result[0]['completion_date'], isNotNull,
        reason: "Completion date should not be null");

    // Cleanup
    await Storage.storage.deleteActivityLog(ActivityName.breathe);
    Storage.storage.close();
  });

//END OF TEST SUITE*****************8
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
