import 'dart:math';
import 'package:gif/gif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/lesson_controller.dart';
import 'package:flutter_hands/screens/lesson/widgets/intro_text.dart';
import 'package:flutter_hands/base/res/animations/pulsing_effect.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';

class MathLessonScreen extends StatefulWidget {
  const MathLessonScreen({super.key});

  @override
  State<MathLessonScreen> createState() => _MathLessonScreenState();
}

class _MathLessonScreenState extends State<MathLessonScreen>
    with TickerProviderStateMixin {
  late String digits;
  late int sum;
  late int num;
  late int subtrahend;
  int difference = 0;
  late bool twoDigit;
  bool isSubtraction = false;

  late final Random _random;
  late final LessonController _controller;
  late final GifController _firstGifController;
  late final GifController _secondGifController;

  @override
  void initState() {
    super.initState();
    _controller = LessonController(
        setState: setState,
        numberSequences: _numberSequences,
        onLastContinueTapped: () {
          twoDigit = false;
          isSubtraction = true;
          generateNumberForSubtraction(); // This will generate a new number and update the state
        },
        goBackToLessonScreen: () {
          Navigator.of(context).pop();
        });
    _random = Random();

    generateNumberforAddition();

    _firstGifController = GifController(vsync: this);
    _firstGifController.addListener(_handleFirstGifCompletion);
    _secondGifController = GifController(vsync: this);
    _secondGifController.addListener(_handleSecondGifCompletion);
  }

  final List<List<IntroText>> _numberSequences = [
    [
      const IntroText(text: "Good job on making this far!"),
      const IntroText(
          text:
              "Now, we're going to apply what you have learn into mathematical operation"),
      const IntroText(text: "Here's an example of addition,"),
      const IntroText(text: "%firstDigit% + %secondDigit%"),
      const IntroText(text: "The answer will be %sum%:"),
    ],
    [
      const IntroText(text: "Now, let's try subtraction!"),
      const IntroText(
          text: "Just like addition, we'll break numbers into digits."),
      const IntroText(text: "Here's an example of subtraction:"),
      const IntroText(text: "%firstDigit% - %secondDigit%"),
      const IntroText(text: "The answer will be %difference%!"),
    ]
  ];

  void generateNumberforAddition() {
    setState(() {
      num = _random.nextInt(99) + 1;
      digits = num.toString().padLeft(2, '0');
      sum = int.parse(digits[0]) + int.parse(digits[1]);
      twoDigit = sum >= 10;
    });
  }

  void generateNumberForSubtraction() {
    setState(() {
      num = _random.nextInt(10);
      subtrahend = _random.nextInt(num + 1);
      digits = num.toString() + subtrahend.toString();
      difference = num - subtrahend;
      print("difference");
    });
  }

  String _processText(String text) {
    return text
        .replaceAll('%firstDigit%', digits[0])
        .replaceAll('%secondDigit%', digits[1])
        .replaceAll('%sum%', sum.toString())
        .replaceAll('%difference%', difference.toString());
  }

  void _handleFirstGifCompletion() {
    if (_firstGifController.isCompleted) {
      setState(() {
        _controller.state.showContinue = true;
      });
    }
  }

  void _handleSecondGifCompletion() {
    if (_secondGifController.isCompleted) {
      setState(() {
        _controller.state.showContinue = true;
      });
    }
  }

  Widget _buildGifDisplayForAddition() {
    double gifSize =
        MediaQuery.of(context).size.width * 0.35; // 35% of screen width

    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center the row contents
      mainAxisSize: MainAxisSize.min, // Take minimum space needed
      children: [
        if (!twoDigit)
          SizedBox(
            width: gifSize,
            height: gifSize,
            child: Gif(
              image: AssetImage(!isSubtraction
                  ? AppMedia.handGif[sum]
                  : AppMedia.handGif[difference]),
              autostart: Autostart.once,
              controller: _firstGifController,
            ),
          )
        else ...[
          SizedBox(
            width: gifSize,
            height: gifSize,
            child: Gif(
              image: AssetImage(AppMedia.handGif[int.parse(sum.toString()[0])]),
              autostart: Autostart.once,
              controller: _firstGifController,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("+", style: AppStyles.headLineStyle2),
          ),
          SizedBox(
            width: gifSize,
            height: gifSize,
            child: Gif(
              image: AssetImage(AppMedia.handGif[int.parse(sum.toString()[1])]),
              autostart: Autostart.once,
              controller: _secondGifController,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextSequence() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_controller.state.currentTextIndex + 1, (i) {
        final isCurrentText = i == _controller.state.currentTextIndex;
        return Padding(
          padding: EdgeInsets.only(bottom: isCurrentText ? 0 : 20),
          child: ReadingEffect(
            text: _processText(_controller.state.currentTexts[i].text),
            style: isCurrentText
                ? AppStyles.headLineStyle2
                : AppStyles.headLineStyle2.copyWith(color: Colors.white54),
            speed: 30,
            animate: isCurrentText,
            onAnimationComplete: isCurrentText
                ? () => setState(() => _controller.state.showContinue = true)
                : null,
          ),
        );
      }),
    );
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
          onTap: _controller.handleTap,
          behavior: HitTestBehavior.opaque,
          child: SafeArea(
              child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTextSequence(),
              const SizedBox(height: 35),
              if (_controller.state.showGif)
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Center(child: _buildGifDisplayForAddition())),
              if (_controller.state.showContinue) const PulsingEffect(),
            ],
          )),
        ));
  }

  @override
  void dispose() {
    _firstGifController.removeListener(_handleFirstGifCompletion);
    _secondGifController.removeListener(_handleSecondGifCompletion);

    _firstGifController.dispose();
    _secondGifController.dispose();

    super.dispose();
  }
}
