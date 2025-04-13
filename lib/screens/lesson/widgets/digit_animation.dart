import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DigitAnimation extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int speed;

  const DigitAnimation({
    super.key,
    required this.text,
    this.style,
    required this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: 10,
          child: Wrap(
            alignment: WrapAlignment.center,
            children: text
                .split('')
                .map((char) => Text(char, style: style))
                .toList()
                .animate(
              interval: speed.ms,
              effects: [
                FadeEffect(delay: 500.ms, duration: 500.ms),
                ScaleEffect(
                    begin: const Offset(0.2, 0.2),
                    end: const Offset(2.0, 2.0),
                    duration: 500.ms),
                MoveEffect(
                  delay: 2000.ms,
                  begin: const Offset(0, 50),
                  end: const Offset(0, 0),
                  duration: 600.ms,
                  curve: Curves.easeOut,
                ),
                ScaleEffect(
                    delay: 2000.ms,
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(0.5, 0.5),
                    duration: 600.ms,
                    curve: Curves.easeOut),
              ],
            ),
          ),
        );
      },
    );
  }
}