import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/animations/pulsing_effect.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key, required this.name});

  final String name;

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  final List<IntroText> _introTexts = [
    const IntroText(text: "Hello there, %name%", isDynamic: true),
    const IntroText(text: "Let us teach you how to sign numbers 0 to 9"),
    const IntroText(text: "First, number one (1)"),
    // Add more introduction texts here as needed
  ];

  int _currentTextIndex = 0;
  bool _showContinue = false;

  void _handleTap() {
    if (_showContinue) {
      setState(() {
        if (_currentTextIndex < _introTexts.length - 1) {
          _currentTextIndex++;
          _showContinue = false;
        } else {
          // Handle final action or navigation
        }
      });
    }
  }

  String _processText(String text) {
    return text.replaceAll('%name%', widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppStyles.backgroundColor,
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i <= _currentTextIndex; i++)
                  Padding(
                    padding: EdgeInsets.only(bottom: i == _currentTextIndex ? 0 : 20),
                    child: ReadingEffect(
                      text: _processText(_introTexts[i].text),
                      style: i == _currentTextIndex ? AppStyles.headLineStyle2 : AppStyles.headLineStyle2.copyWith(color: Colors.white54),
                      effect: AnimationEffect.typewriter,
                      onAnimationComplete: i == _currentTextIndex
                          ? () => setState(() => _showContinue = true)
                          : null,
                    ),
                  ),
                if (_showContinue)
                  const PulsingEffect(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IntroText {
  final String text;
  final bool isDynamic;

  const IntroText({required this.text, this.isDynamic = false});
}