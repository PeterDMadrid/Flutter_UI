import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';

class Heading extends StatelessWidget {
  const Heading({super.key, required this.headingText});
  final String headingText;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Column(
            children: [
              const SizedBox(height: 40),
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 500)),
                  SlideEffect(
                    begin: Offset(0, -0.1),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 500),
                  ),
                ],
                child: Text(
                  headingText,
                  style: AppStyles.getHeadLineStyle1(isDarkMode),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        });
  }
}
