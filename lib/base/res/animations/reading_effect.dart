import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ReadingEffect extends StatefulWidget {
  const ReadingEffect({
    super.key,
    required this.text,
    this.style,
    this.effect = AnimationEffect.fadeIn,
    this.onAnimationComplete,
  });

  final String text;
  final TextStyle? style;
  final AnimationEffect effect;
  final VoidCallback? onAnimationComplete;

  @override
  State<ReadingEffect> createState() => _ReadingEffectState();
}

class _ReadingEffectState extends State<ReadingEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.effect == AnimationEffect.typewriter
          ? Duration(milliseconds: 60 * widget.text.length)
          : const Duration(milliseconds: 600),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _isComplete = true);
        widget.onAnimationComplete?.call();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.effect) {
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
      children: widget.text.characters.map((char) {
        return Animate(
          controller: _controller,
          effects: [
            FadeEffect(duration: 400.ms, curve: Curves.easeInOut),
            ScaleEffect(
                begin: const Offset(0, 0),
                end: const Offset(1.0, 1.0),
                duration: 400.ms),
            MoveEffect(
              begin: const Offset(-20, 0),
              end: Offset.zero,
              duration: 400.ms,
              curve: Curves.easeOutCubic,
            ),
          ],
          delay: 100.ms * widget.text.indexOf(char),
          child: Text(
            char,
            style: widget.style,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypewriterText() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final value = _controller.value;
        return Text(
          widget.text.substring(0, (widget.text.length * value).floor()),
          style: widget.style,
        );
      },
    );
  }

  Widget _buildWaveText() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.text.characters.map((char) {
        return Animate(
          controller: _controller,
          effects: [
            FadeEffect(duration: 600.ms),
            ScaleEffect(
                begin: const Offset(0, 0),
                end: const Offset(1.0, 1.0),
                duration: 600.ms),
            MoveEffect(
              begin: const Offset(-20, 0),
              end: Offset.zero,
              duration: 600.ms,
              curve: Curves.easeOutCubic,
            ),
          ],
          delay: 80.ms * widget.text.indexOf(char),
          child: Text(
            char,
            style: widget.style,
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
