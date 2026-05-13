import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';

class PulsingEffect extends StatelessWidget {
  const PulsingEffect({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Animate(
            effects: [
              FadeEffect(
                begin: 1,
                end: 0.2,
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
              FadeEffect(
                begin: 0.2,
                end: 1,
                duration: 900.ms,
                curve: Curves.easeInOut,
              ),
            ],
            onComplete: (controller) => controller.repeat(),
            child: Padding(
              padding: const EdgeInsets.only(top: 16.0, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "continue",
                    style: TextStyle(color: isDarkMode?Colors.white: Colors.black),
                  ),
                  Icon(
                    Icons.arrow_right_rounded,
                    color: isDarkMode?Colors.white: Colors.black,
                  )
                ],
              ),
            ),
          ).animate().fade(duration: 500.ms).slide(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
                duration: 200.ms,
              );
        });
  }
}
