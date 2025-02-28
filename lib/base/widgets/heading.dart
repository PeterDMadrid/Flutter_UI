import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class Heading extends StatelessWidget {
  const Heading({super.key, required this.headingText});
  final String headingText;

  @override
  Widget build(BuildContext context) {
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
            style: AppStyles.headLineStyle1,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
