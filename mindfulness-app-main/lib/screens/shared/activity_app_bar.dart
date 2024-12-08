import 'dart:ui';
import 'package:flutter/material.dart';

AppBar activityAppBar(String title, Color backgroundColor, BuildContext context, bool activityCompleted) {
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
        color: Colors.white,
        onPressed: () {Navigator.pop(context, activityCompleted);},
      ));
}
