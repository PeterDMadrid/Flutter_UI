import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class HeadingProfile extends StatelessWidget {
  final String headingText;
  final Color? customColor;
  final bool isDarkMode;

  const HeadingProfile({
    super.key,
    required this.headingText,
    this.customColor,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final headingColor = customColor ??
        (isDarkMode ? AppStyles.headlineColor : AppStyles.lightHeadlineColor);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Text(
            headingText,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: headingColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    isDarkMode ? AppStyles.myblue : AppStyles.lightMyBlue,
                    isDarkMode ? Colors.transparent : Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
