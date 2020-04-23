import 'package:flutter/material.dart';

class Style {
  static final Color primaryColor = Colors.blue;
  static final Color secondaryColor = Colors.lightBlueAccent;
  static final Color textColor = Colors.white;
  static final Color darkColor = Color(0xFF4382d8);
  static final List<Color> gradientColors = [primaryColor, secondaryColor];

  //text styles
  static final TextStyle appNameTextStyle =
      TextStyle(fontSize: 32, fontWeight: FontWeight.w500);
  //decorations
  static InputDecoration formInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white),
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: Colors.white),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: Colors.cyan),
      ),
      errorStyle: TextStyle(color: Colors.white),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        borderSide: BorderSide(color: Colors.white),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22),
        // borderSide: BorderSide(color: Colors.red),
      ),
    );
  }
}
