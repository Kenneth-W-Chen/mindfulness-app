import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart'; // Import path for file path handling in tests
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import sqflite_common_ffi for desktop testing
import '../lib/storage.dart'; // Import your storage class to test its functionality

void main(){

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  //Creation operation and close operation
  test('CREATION AND CLOSE TEST', () async {

    String dbPath = join(await getDatabasesPath(), 'test_storage.db');

    Storage storage = await Storage.create(dbName: dbPath);

    expect(storage, isNotNull);

    expect(dbPath.contains('test_storage.db'), true);
    
    storage.close();


  });
}


/// Prints the activities table using the existing method
Future<void> printActivitiesTable(Storage storage) async {
  var activityLogs = await storage.getActivityLogs([ActivityName.breathe, ActivityName.all]);
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
  var achievements = await storage.getAchievementsCompletionDate([Achievement.all]);
  print('Achievements Table:');
  achievements.forEach((achievement, date) {
    print('$achievement -> $date');
  });
}