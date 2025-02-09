import 'package:flutter/material.dart';

AppBar activityAppBar(String title, Color backgroundColor, BuildContext context, bool activityCompleted, {Color? backButtonColor = Colors.white}) {
  return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          letterSpacing: 1.2,
        ),
      ),
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: BackButton(
        color: backButtonColor,
        onPressed: () {Navigator.pop(context, activityCompleted);},
      ));
}
