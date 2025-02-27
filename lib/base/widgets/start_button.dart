import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class StartButton extends StatelessWidget {
  const StartButton({
    super.key,
    required this.onTap,
    required this.text,
    this.color,
    this.iconSize = 36,
    this.fontSize = 32,
    this.height = 80,
  });

  final VoidCallback onTap;
  final String text;
  final Color? color;
  final double iconSize;
  final double fontSize;
  final double height;

  @override
  Widget build(BuildContext context) {
    Color effectiveColor;
    if (text.toLowerCase() == "addition") {
      effectiveColor = AppStyles.khaki;
    } else if (text.toLowerCase() == "subtraction") {
      effectiveColor = AppStyles.myblue;
    } else {
      effectiveColor =
          color ?? AppStyles.buttonColor;
    }

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, curve: Curves.easeOut),
        ScaleEffect(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOut),
      ],
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppStyles.boxShadowColor.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: height,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  effectiveColor.withOpacity(0.9),
                  effectiveColor,
                  effectiveColor.withOpacity(0.85),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: fontSize,
                    color: Colors.white,
                    letterSpacing: 1.4,
                    shadows: [
                      Shadow(
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.play_circle_filled_rounded,
                  size: iconSize,
                  color: Colors.white.withOpacity(0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
