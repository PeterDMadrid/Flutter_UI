import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PulsingEffect extends StatelessWidget {
  const PulsingEffect({super.key});

  @override
  Widget build(BuildContext context) {
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
      child: const Padding(
        padding: EdgeInsets.only(top: 16.0, right: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, 
          children: [
            Text(
              "continue",
              style: TextStyle(color: Colors.white),
            ),
            Icon(Icons.arrow_right_rounded, color: Colors.white,)
          ],
        ),
      ),
    ).animate()
      .fade(duration: 500.ms)
      .slide(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
        duration: 200.ms,
      );
  }
}
