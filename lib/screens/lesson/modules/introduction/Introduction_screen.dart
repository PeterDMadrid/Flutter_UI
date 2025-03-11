import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/widgets/number_selection.dart';
import 'package:flutter_hands/controllers/lesson_controller.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/screens/lesson/widgets/intro_text.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';
import 'package:flutter_hands/base/res/animations/pulsing_effect.dart';
import 'package:flutter_hands/screens/lesson/widgets/gif_display.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key, required this.name});

  final String name;

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction> {
  late final LessonController _controller;

  final List<List<IntroText>> _numberSequences = [
    [
      const IntroText(text: "Hi, %name%! Are you ready to learn some signs?"),
      const IntroText(text: "Let's start with the number zero."),
      const IntroText(
          text:
              "To sign zero, make a circle with your hand. Let's try it together!"),
    ],
    [
      const IntroText(
          text: "Great job with zero! Now, let's learn number one."),
      const IntroText(
          text: "To sign one, hold up your index finger. Can you show me?"),
    ],
    [
      const IntroText(text: "Awesome! Now, let's learn number two."),
      const IntroText(
          text:
              "To sign two, hold up your index and middle fingers. Let's practice!"),
    ],
    [
      const IntroText(
          text: "You're doing great! Now, let's learn number three."),
      const IntroText(
          text:
              "To sign three, hold up your thumb, index, and middle fingers. Can you show me?"),
    ],
    [
      const IntroText(text: "Next is number four."),
      const IntroText(
          text:
              "To sign four, hold up four fingers and tuck in your thumb. Let's try it!"),
    ],
    [
      const IntroText(text: "High five! Now, let's learn number five."),
      const IntroText(
          text: "To sign five, spread all your fingers wide. Can you show me?"),
    ],
    [
      const IntroText(text: "Great! Now, let's learn number six."),
      const IntroText(
          text:
              "To sign six, hold up your pinky and thumb, with the other fingers tucked in."),
      const IntroText(
          text:
              "Be careful! Number six can look like number three if you don't tuck in your other fingers. Make sure to keep them hidden!"),
    ],
    [
      const IntroText(
          text: "You're doing awesome! Now, let's learn number seven."),
      const IntroText(
          text:
              "To sign seven, hold up your ring finger and thumb, with the other fingers tucked in."),
      const IntroText(
          text:
              "Watch out! Number seven can be confused with number eight, so remember to keep your middle finger down for seven."),
    ],
    [
      const IntroText(text: "Almost done! Now, let's learn number eight."),
      const IntroText(
          text:
              "To sign eight, hold up your middle finger and thumb, with the other fingers tucked in."),
      const IntroText(
          text:
              "Remember, number eight has the middle finger up, while number seven has the ring finger up."),
    ],
    [
      const IntroText(text: "You did it! Now, let's finish with number nine."),
      const IntroText(
          text:
              "To sign nine, hold up your index finger and thumb, with the other fingers tucked in."),
      const IntroText(
          text:
              "Be careful! Number nine can look like number three if you don't tuck in your other fingers. Make sure to keep them hidden!"),
    ],
  ];

  @override
  void initState() {
    super.initState();
    _controller = LessonController(
      setState: setState,
      numberSequences: _numberSequences,
    );
  }

  String _processText(String text) {
    return text.replaceAll('%name%', widget.name);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
              iconTheme: IconThemeData(
                  color: isDarkMode ? Colors.white : Colors.black87),
            ),
            backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
            body: Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTap: _controller.handleTap,
                  behavior: HitTestBehavior.opaque,
                  child: SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        ...List.generate(_controller.state.currentTextIndex + 1,
                            (i) {
                          final isCurrentText =
                              i == _controller.state.currentTextIndex;
                          return Padding(
                            padding:
                                EdgeInsets.only(bottom: isCurrentText ? 0 : 20),
                            child: ReadingEffect(
                              text: _processText(
                                  _controller.state.currentTexts[i].text),
                              style: isCurrentText
                                  ? AppStyles.getHeadLineStyle2(isDarkMode)
                                  : isDarkMode
                                      ? AppStyles.headLineStyle2
                                          .copyWith(color: Colors.white54)
                                      : AppStyles.lightHeadLineStyle2
                                          .copyWith(color: const Color.fromARGB(137, 17, 17, 17)),
                              speed: 30,
                              animate: isCurrentText,
                              onAnimationComplete: isCurrentText
                                  ? () => setState(() =>
                                      _controller.state.showContinue = true)
                                  : null,
                            ),
                          );
                        }),
                        if (_controller.state.showGif) ...[
                          const SizedBox(height: 20),
                          GifDisplay(
                            gifPath: AppMedia
                                .handGif[_controller.state.currentNumber - 1],
                            staticFramePath: AppMedia.handFrames[
                                _controller.state.currentNumber - 1],
                            onGifDisplayed: () {
                              Future.delayed(
                                const Duration(milliseconds: 2500),
                                () => setState(() =>
                                    _controller.state.showContinue = true),
                              );
                            },
                          ),
                        ],
                        if (_controller.state.showContinue)
                          const PulsingEffect(),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: NumberSelection(
                    onNumberSelected: _controller.handleNumberSelection,
                  ),
                ),
              ],
            ),
          );
        });
  }
}
