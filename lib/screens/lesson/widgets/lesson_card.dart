import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.lessonTitle,
    required this.lessonSubtitle,
    required this.lessonIcon,
    required this.onPressed,
    this.index = 0,
  });

  final String lessonTitle;
  final String lessonSubtitle;
  final String lessonIcon;
  final VoidCallback onPressed;
  final int index;

  @override
  Widget build(BuildContext context) {
    Color startColor = AppStyles.myblue.withOpacity(0.6);
    Color endColor = AppStyles.lavender;

    return Animate(
      delay: AppStyles.getStaggeredDelay(index),
      effects: AppStyles.cardEntranceEffects2(),
      child: Container(
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
            image: AssetImage(lessonIcon),
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
                lessonTitle,
                style: AppStyles.headLineStyle2,
              ),
              Text(
                lessonSubtitle,
                style: AppStyles.paragraph2,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onPressed,
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
      ),
    );
  }
}