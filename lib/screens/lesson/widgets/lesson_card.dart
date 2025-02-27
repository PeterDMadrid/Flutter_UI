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
    Color startColor = AppStyles.myblue.withOpacity(0.8);
    Color endColor = AppStyles.lavender.withOpacity(0.9);

    return Animate(
      delay: AppStyles.getStaggeredDelay(index),
      effects: AppStyles.cardEntranceEffects2(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
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
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppStyles.boxShadowColor,
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 32,
                        width: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            "${index + 1}",
                            style: TextStyle(
                              color: AppStyles.headlineColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        lessonTitle,
                        style: AppStyles.headLineStyle2.copyWith(
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lessonSubtitle,
                    style: AppStyles.paragraph2.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyles.buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Start Lesson",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Overflowing Image
          Positioned(
            right: -10,
            top: -25,
            bottom: -25,
            child: Image.asset(
              lessonIcon,
              width: 185,
              fit: BoxFit.contain,
              opacity: const AlwaysStoppedAnimation(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
