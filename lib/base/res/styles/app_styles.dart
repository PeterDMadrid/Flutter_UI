import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppStyles {
  //dark mode:
  static Color backgroundColor = const Color(0xFF102A43);
  static Color textColor = const Color(0xFFC6C6C6);
  static Color headlineColor = const Color(0xFFDCDCDC);
  static TextStyle darkTextStyle =
      const TextStyle(fontSize: 26, color: Color(0xFF0B0B0B));
  static TextStyle headLineStyle1 = TextStyle(
      fontSize: 26, fontWeight: FontWeight.bold, color: headlineColor);
  static TextStyle headLineStyle2 = const TextStyle(
      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber);
  static TextStyle paragraph1 =
      const TextStyle(fontSize: 21, color: Colors.white);
  static TextStyle paragraph2 =
      TextStyle(fontSize: 16, color: textColor, height: 1.5);
  static Color myblue = const Color.fromARGB(255, 9, 70, 92);

  //light mode:
  static Color lightBackgroundColor = const Color(0xFFFFFFFF);
  static Color lightTextColor = const Color.fromARGB(255, 32, 32, 32);
  static Color lightHeadlineColor = const Color.fromARGB(255, 14, 14, 14);
  static TextStyle lightTextStyle =
      const TextStyle(fontSize: 26, color: Color.fromARGB(255, 255, 255, 255));
  static TextStyle lightHeadLineStyle1 = TextStyle(
      fontSize: 26, fontWeight: FontWeight.bold, color: lightHeadlineColor);
  static TextStyle lightHeadLineStyle2 = TextStyle(
      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber[800]);
  static TextStyle lightParagraph1 =
      const TextStyle(fontSize: 21, color: Colors.black);
  static TextStyle lightParagraph2 =
      TextStyle(fontSize: 16, color: lightTextColor, height: 1.5);
  static Color lightMyBlue = const Color.fromARGB(255, 83, 209, 255);

//getters
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? backgroundColor : lightBackgroundColor;
  }

  static Color getMyBlue(bool isDarkMode) {
    return isDarkMode ? myblue : lightMyBlue;
  }

  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? textColor : lightTextColor;
  }

  static Color getHeadLineColor(bool isDarkMode) {
    return isDarkMode ? headlineColor : lightHeadlineColor;
  }

  static TextStyle getTextStyle(bool isDarkMode) {
    return isDarkMode ? darkTextStyle : lightTextStyle;
  }

  static TextStyle getHeadLineStyle1(bool isDarkMode) {
    return isDarkMode ? headLineStyle1 : lightHeadLineStyle1;
  }

  static TextStyle getHeadLineStyle2(bool isDarkMode) {
    return isDarkMode ? headLineStyle2 : lightHeadLineStyle2;
  }

  static TextStyle getParagraph1(bool isDarkMode) {
    return isDarkMode ? paragraph1 : lightParagraph1;
  }

  static TextStyle getParagraph2(bool isDarkMode) {
    return isDarkMode ? paragraph2 : lightParagraph2;
  }

//static
  static Color roseRed = const Color.fromARGB(255, 184, 50, 72);
  static Color lavender = const Color(0xFF7A32A9);
  static Color buttonColor = const Color.fromARGB(255, 55, 133, 221);
  static Color khaki = const Color.fromARGB(255, 206, 192, 65);
  static Color boxShadowColor = const Color(0xFF0D1B2A);

  static Duration getStaggeredDelay(int index,
      {Duration baseDelay = const Duration(milliseconds: 100)}) {
    return baseDelay * index;
  }

  static const Duration defaultAnimationDuration = Duration(milliseconds: 400);
  static const Curve defaultAnimationCurve = Curves.easeOutCubic;

  // Reusable animation effects
  static List<Effect> cardEntranceEffects({
    Duration duration = defaultAnimationDuration,
    double slideDistance = 30.0,
    double scaleStart = 0.95,
    double blurStart = 8.0,
  }) =>
      [
        ScaleEffect(
          begin: Offset(scaleStart, scaleStart),
          end: const Offset(1, 1),
          duration: duration,
          curve: defaultAnimationCurve,
        ),
        MoveEffect(
          begin: Offset(0.0, slideDistance),
          end: const Offset(0.0, 0.0),
          duration: duration,
          curve: defaultAnimationCurve,
        ),
        FadeEffect(
          begin: 0.0,
          end: 1.0,
          duration: duration,
          curve: Curves.easeOut,
        ),
        CustomEffect(
          begin: blurStart,
          end: 0.0,
          duration: duration,
          curve: defaultAnimationCurve,
          builder: (context, value, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: child,
            );
          },
        ),
      ];

  static List<Effect> cardEntranceEffects2({
    Duration duration = defaultAnimationDuration,
    double slideDistance = 50.0,
  }) =>
      [
        MoveEffect(
          begin: Offset(slideDistance, 0.0), // Slide from right
          end: const Offset(0.0, 0.0),
          duration: duration,
          curve: Curves.easeOutQuart, // Slightly different curve for variety
        ),
        FadeEffect(
          begin: 0.0,
          end: 1.0,
          duration: duration,
          curve: Curves.easeOut,
        ),
      ];
}
