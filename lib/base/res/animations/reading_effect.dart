import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReadingEffect extends StatelessWidget {
  const ReadingEffect({
    super.key,
    required this.text,
    this.style,
    this.effect = AnimationEffect.fadeIn,
  });

  final String text;
  final TextStyle? style;
  final AnimationEffect effect;

  @override
  Widget build(BuildContext context) {
    switch (effect) {
      case AnimationEffect.fadeIn:
        return _buildFadeInText();
      case AnimationEffect.typewriter:
        return _buildTypewriterText();
      case AnimationEffect.wave:
        return _buildWaveText();
    }
  }

  Widget _buildFadeInText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: text.characters.map((char) {
        return Animate(
          effects: [
            FadeEffect(duration: 400.ms, curve: Curves.easeInOut),
            ScaleEffect(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: 400.ms
            ),
          ],
          delay: 100.ms * text.indexOf(char),
          child: Text(
            char,
            style: style,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypewriterText() {
    return Animate(
      effects: [
        CustomEffect(
          duration: 1000.ms,
          builder: (context, value, child) {
            return Text(
              text.substring(0, (text.length * value).floor()),
              style: style,
            );
          },
        ),
      ],
    );
  }

  Widget _buildWaveText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: text.characters.map((char) {
        return Animate(
          effects: [
            FadeEffect(duration: 600.ms),
            ScaleEffect(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: 600.ms
            ),
            MoveEffect(
              begin: const Offset(0, 10),
              end: Offset.zero,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            ),
          ],
          delay: 80.ms * text.indexOf(char),
          child: Text(
            char,
            style: style,
          ),
        );
      }).toList(),
    );
  }
}

enum AnimationEffect {
  fadeIn,
  typewriter,
  wave,
}
