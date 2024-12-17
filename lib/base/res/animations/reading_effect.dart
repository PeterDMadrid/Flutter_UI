import 'package:flutter/material.dart';

class ReadingEffect extends StatefulWidget {
  const ReadingEffect({
    super.key,
    required this.text,
    this.style,
    this.onAnimationComplete,
    this.animate = true,
  });

  final String text;
  final TextStyle? style;
  final VoidCallback? onAnimationComplete;
  final bool animate;

  @override
  State<ReadingEffect> createState() => _ReadingEffectState();
}

class _ReadingEffectState extends State<ReadingEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.animate ? 30 * widget.text.length : 0),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ReadingEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text || oldWidget.animate != widget.animate) {
      _controller.duration = Duration(milliseconds: widget.animate ? 30 * widget.text.length : 0);
      if (widget.animate) {
        _controller.forward(from: 0);
      } else {
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return Text(widget.text, style: widget.style);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final textLength = (widget.text.length * _animation.value).floor();
        return Text(
          widget.text.substring(0, textLength),
          style: widget.style,
        );
      },
    );
  }
}