import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class TipBox extends StatelessWidget {
  final int staggerDelay;
  const TipBox({super.key, required this.staggerDelay});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Animate(
        effects: AppStyles.cardEntranceEffects2(),
        delay: AppStyles.getStaggeredDelay(staggerDelay),
        child: Container(
          height: 100,
          width: screenWidth - 40,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppStyles.myblue.withOpacity(0.3),
                AppStyles.lavender.withOpacity(0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppStyles.myblue.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppStyles.boxShadowColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppStyles.khaki,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Learning Tip",
                      style: TextStyle(
                        color: AppStyles.headlineColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Practice each sign regularly to build muscle memory for better recognition.",
                      style: TextStyle(
                        color: AppStyles.textColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}