import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';

class TipBox extends StatelessWidget {
  final int staggerDelay;
  const TipBox({super.key, required this.staggerDelay});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
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
                    colors: isDarkMode
                        ? [
                            AppStyles.myblue.withOpacity(0.3),
                            AppStyles.lavender.withOpacity(0.3),
                          ]
                        : [
                            Colors.white70,
                            Colors.grey.shade100,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDarkMode
                        ? AppStyles.myblue.withOpacity(0.5)
                        : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? AppStyles.boxShadowColor.withOpacity(0.3)
                          : Colors.grey.shade200.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color:
                          isDarkMode ? AppStyles.khaki : Colors.amber.shade700,
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
                              color: isDarkMode
                                  ? AppStyles.headlineColor
                                  : Colors.black87,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Practice each sign regularly to build muscle memory for better recognition.",
                            style: TextStyle(
                              color: isDarkMode
                                  ? AppStyles.textColor
                                  : Colors.black54,
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
        });
  }
}
