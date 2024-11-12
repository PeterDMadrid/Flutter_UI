import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lessonName,
    required this.lessonIcon,
  });

  final String lessonName;
  final String lessonIcon;

  @override
  Widget build(BuildContext context) {
    Color startColor = AppStyles.myblue.withOpacity(0.6);
    Color endColor = AppStyles.lavender;
    String backgroundImage = lessonIcon;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 120,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(backgroundImage),
          fit: BoxFit.none,
          scale: 2.5,
          alignment: const Alignment(0.9, -0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              lessonName,
              style: AppStyles.headLineStyle2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppStyles.buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Start Lesson",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
