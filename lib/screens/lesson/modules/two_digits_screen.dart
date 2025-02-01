import 'dart:math';
import 'package:gif/gif.dart';
import '../widgets/intro_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/lesson_controller.dart';
import 'package:flutter_hands/screens/lesson/widgets/gif_display.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';
import 'package:flutter_hands/base/res/animations/pulsing_effect.dart';

class TwoDigitsScreen extends StatefulWidget {
  const TwoDigitsScreen({super.key});

  @override
  State<TwoDigitsScreen> createState() => _TwoDigitsScreenState();
}

class _TwoDigitsScreenState extends State<TwoDigitsScreen>
    with TickerProviderStateMixin {
  late int currentGif;
  final Random random = Random();
  late int twoDigitNumber;
  late String numberString = twoDigitNumber.toString();

  late final LessonController _controller;
  late GifController _gifController;

  final List<List<IntroText>> _numberSequences = [
    [
      const IntroText(text: "What about a two digit number?"),
      const IntroText(
          text:
              "To sign a two digit number, you would simply sign the number itself twice"),
      const IntroText(text: "For Example: %twodigitnumber%"),
    ],
  ];

  int generateTwoDigitNumber() {
    return 10 + random.nextInt(90);
  }

  void _restartGif() {
    setState(() {
      currentGif = 0;
      _gifController.reset();
    });
  }

  String _processText(String text) {
    return text.replaceAll('%twodigitnumber%', numberString);
  }

  @override
  void initState() {
    super.initState();

    twoDigitNumber = generateTwoDigitNumber();
    _controller = LessonController(
      setState: setState,
      numberSequences: _numberSequences,
    );

    _gifController = GifController(vsync: this);
    _gifController.addListener(() {
      if (_gifController.isCompleted) {
        setState(() {
          if (currentGif < 1) {
            currentGif++;
          } else {
            _restartGif();
          }
        });
      }
    });

    currentGif = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppStyles.backgroundColor,
      body: Stack(fit: StackFit.expand, children: [
        GestureDetector(
          onTap: _controller.handleTap,
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ...List.generate(_controller.state.currentTextIndex + 1, (i) {
                  final isCurrentText = i == _controller.state.currentTextIndex;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isCurrentText ? 0 : 20),
                    child: ReadingEffect(
                      text:
                          _processText(_controller.state.currentTexts[i].text),
                      style: isCurrentText
                          ? AppStyles.headLineStyle2
                          : AppStyles.headLineStyle2
                              .copyWith(color: Colors.white54),
                      animate: isCurrentText,
                      onAnimationComplete: isCurrentText
                          ? () => setState(
                              () => _controller.state.showContinue = true)
                          : null,
                    ),
                  );
                }),
                if (_controller.state.showGif) ...[
                  const SizedBox(height: 35),
                  if (currentGif == 0)
                    Column(
                      children: [
                        Gif(
                          image: AssetImage(
                              AppMedia.handGif[int.parse(numberString[0])]),
                          autostart: Autostart.once,
                          controller: _gifController,
                        ),
                        const SizedBox(height: 5,),
                        Text(numberString[0], style: AppStyles.headLineStyle2,),
                      ],
                    )
                  else if (currentGif == 1)
                    Column(
                      children: [
                        Gif(
                          image: AssetImage(
                              AppMedia.handGif[int.parse(numberString[1])]),
                          autostart: Autostart.once,
                          controller: _gifController,
                        ),
                        const SizedBox(height: 5),
                        Text(numberString[0]+numberString[1], style: AppStyles.headLineStyle2,),
                      ],
                    ),
                ],
                if (_controller.state.showContinue) const PulsingEffect(),
              ],
            ),
          ),
        )
      ]),
    );
  }
}
