import 'dart:math';

import 'package:calm_quest/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AchievementsSystem {
  static late final SharedPreferences prefs;

  /// Initializes the achievements system. Should not be called outside of ``main.dart``.
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  /// Updates an achievement's conditional flag/value and marks the achievement as complete if its condition is met.
  /// Usage:
  /// ```dart
  /// await AchievementsSystem.updateAchievementCondition(Achievement.{achievementName}, 1);
  /// ```
  ///
  /// Example:
  /// ```dart
  /// await AchievementsSystem.updateAchievementCondition(Achievement.calm_shield, 1);
  /// ```
  static Future<void> updateAchievementCondition(Achievement achievement, int value) async {
    assert(value > 0);
    if (achievement.flagBitmask) {
      await _setFlag(achievement, value);
    } else {
      await _incrementCondition(achievement, value);
    }
  }

  /// Private function for setting bitmask achievement unlock conditions
  static Future<void> _setFlag(Achievement achievement, int flag) async {
    // get previous value prior
    int prevFlag = prefs.getInt(achievement.name) ?? 0;
    // calculate the new value
    int curFlag = prevFlag | flag;
    // stop function if no flags were changed
    if (prevFlag == curFlag) return;

    // calculate the expected flags to be set as a bitmask
    int expectedFlag = (pow(2, achievement.flagC) - 1) as int;

    // stop function if the previous value was already the full bitmask
    if (prevFlag == expectedFlag) return;

    // update the stored flag
    prefs.setInt(achievement.name, curFlag);

    // mark achievement as complete if all flags are set
    if (curFlag == expectedFlag) {
      await _completeAchievement(achievement);
    }
  }

  /// Private function for incrementing value-based achievement unlock conditions (e.g., do something x times)
  static Future<void> _incrementCondition(Achievement achievement, int value) async {
    // get previous value
    int curConditionValue = prefs.getInt(achievement.name) ?? 0;
    // stop function if condition was already met
    if(curConditionValue > achievement.flagC) return;

    // increment value and update stored value
    curConditionValue += value;
    prefs.setInt(achievement.name, curConditionValue);

    // mark achievement as complete if value met
    if(curConditionValue >= achievement.flagC){
      await _completeAchievement(achievement);
    }
  }

  /// Private function to unlock an achievement without updating already unlocked achievements
  static Future<bool> _completeAchievement(Achievement achievement) async {
    if (await Storage.storage.isAchievementCompleted(achievement)) {
      return false;
    }

    await Storage.storage.setAchievementCompleted(achievement);
    return true;
  }
}
