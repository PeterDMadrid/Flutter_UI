import 'package:flutter/material.dart';

class AppStyles {
  static Color textColor = const Color(0xFF3b3b3b);
  static Color roseRed = const Color.fromARGB(255, 184, 50, 72);
  static Color lavender = const Color.fromARGB(255, 122, 50, 177);
  static Color buttonColor = const Color.fromARGB(255, 55, 133, 221);

  static TextStyle headLineStyle1 =
      TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor);

  static TextStyle headLineStyle2 =
      TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor);

  static TextStyle paragraph1 =
      const TextStyle(fontSize: 21, color: Colors.white);

  static TextStyle paragraph2 =
       TextStyle(fontSize: 16, color: textColor, height: 1.5);
}
