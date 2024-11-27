import 'package:flutter/material.dart';

// Method to create activity cards with placeholders for future functionality
Widget activityCard(String activityName, BuildContext context, IconData icon, String description,
    {
      Widget Function(BuildContext buildcontext)? builder = null,
      Color? cardColor, Color? shadowColor, Color? textColor, Color? subTextColor, Color? iconColor, Color? iconBackgroundColor
    }
    ) {
  return GestureDetector(
    onTap: builder == null? () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$activityName feature is under construction!'),
          duration: const Duration(seconds: 2),
        ),
      );
    }:() {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: builder
          ));
    },
    child: Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      elevation: 10,
      shadowColor: shadowColor,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconBackgroundColor,
          child: Icon(icon, color:iconColor, size: 32),
        ),
        title: Text(
          activityName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
            letterSpacing: 1.0,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 16,
            color: subTextColor,
          ),
        ),
      ),
    ),
  );
}
