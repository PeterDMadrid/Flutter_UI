import 'dart:math';
import 'dart:async';
import 'package:gif/gif.dart';
import '../widgets/intro_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/lesson_controller.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';
import 'package:flutter_hands/base/res/animations/pulsing_effect.dart';
import 'package:flutter_hands/screens/lesson/widgets/digit_animation.dart';

class TwoDigitsScreen extends StatefulWidget {
  const TwoDigitsScreen({super.key});

  @override
  State<TwoDigitsScreen> createState() => _TwoDigitsScreenState();
}

class _TwoDigitsScreenState extends State<TwoDigitsScreen>
    with TickerProviderStateMixin {
  // Constants
  static const double _defaultPadding = 16.0;
  static const double _gifSpacing = 35.0;
  static const double _digitSpacing = 5.0;
  static const int _animationSpeed = 30;

  // State variables
  int _currentGif = 0;
  String _numberString;
  bool _isResetting = false;

  late final LessonController _controller;
  late final GifController _gifController;

  final List<List<IntroText>> _numberSequences = [
    [
      const IntroText(text: "What about a two digit number?"),
      const IntroText(
          text:
              "To sign a two digit number, you would simply sign the number itself twice"),
      const IntroText(text: "For Example: %twodigitnumber%"),
    ],
  ];

  _TwoDigitsScreenState()
      : _numberString = (10 + Random().nextInt(90)).toString();

  @override
  void initState() {
    super.initState();

    _controller = LessonController(
      setState: setState,
      numberSequences: _numberSequences,
      onLastContinueTapped: () {
        generateNumber(); // This will generate a new number and update the state
      },
    );

    _gifController = GifController(vsync: this);
    _gifController.addListener(_handleGifCompletion);
  }

  @override
  void dispose() {
    _gifController.removeListener(_handleGifCompletion);
    _gifController.dispose();
    super.dispose();
  }

  // At class level
  final List<String> _recentNumbers = [];
  final int _maxRecentHistory = 10;

  void generateNumber() {
    setState(() {
      _isResetting = true;
      int num;

      do {
        num = 10 + Random().nextInt(90);
      } while (_recentNumbers.contains(num.toString()) || num % 11 == 0);

      _numberString = num.toString();

      // Add to recent numbers and maintain history limit
      _recentNumbers.add(_numberString);
      if (_recentNumbers.length > _maxRecentHistory) {
        _recentNumbers.removeAt(0);
      }

      _currentGif = 0;
      _gifController.reset();

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            _isResetting = false;
          });
        }
      });
    });
  }

  void _handleGifCompletion() {
    if (_isResetting) return;

    if (_numberString[0] == _numberString[1]) {
      _controller.state.showContinue = true;
    } else if (_gifController.isCompleted) {
      setState(() {
        if (_currentGif < 1) {
          _currentGif++;
          _gifController.reset();
        } else {
          _restartGif();
          _controller.state.showContinue = true;
        }
      });
    }
  }

  void _restartGif() {
    if (_isResetting) return;

    setState(() {
      _currentGif = 0;
      _gifController.reset();
    });
  }

  String _processText(String text) {
    return text.replaceAll('%twodigitnumber%', _numberString);
  }

  Widget _buildGifDisplay(String digit, bool isFirstDigit) {
    if (_isResetting) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Gif(
          image: AssetImage(AppMedia.twoDigits[int.parse(digit)]),
          autostart: isFirstDigit && digit == _numberString[1]
              ? Autostart.loop
              : Autostart.once,
          controller: _gifController,
        ),
        const SizedBox(height: _digitSpacing),
      ],
    );
  }

  Widget _buildTextSequence(isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        _controller.state.currentTextIndex + 1,
        (i) {
          final isCurrentText = i == _controller.state.currentTextIndex;
          return Padding(
            padding: EdgeInsets.only(bottom: isCurrentText ? 0 : 20),
            child: ReadingEffect(
              text: _processText(_controller.state.currentTexts[i].text),
              style: isCurrentText
                  ? AppStyles.getHeadLineStyle2(isDarkMode)
                  : isDarkMode
                      ? AppStyles.headLineStyle2.copyWith(color: Colors.white54)
                      : AppStyles.lightHeadLineStyle2.copyWith(
                          color: const Color.fromARGB(137, 17, 17, 17)),
              speed: _animationSpeed,
              animate: isCurrentText,
              onAnimationComplete: isCurrentText
                  ? () => setState(() => _controller.state.showContinue = true)
                  : null,
            ),
          );
        },
      ),
    );
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
                      padding: const EdgeInsets.all(_defaultPadding),
                      children: [
                        _buildTextSequence(isDarkMode),
                        if (_controller.state.showGif) ...[
                          const SizedBox(height: _gifSpacing),
                          if (_currentGif == 0)
                            _buildGifDisplay(_numberString[0], true)
                          else if (_currentGif == 1)
                            _buildGifDisplay(_numberString[1], false),
                          DigitAnimation(
                              text: _numberString,
                              speed: 3000,
                              style: AppStyles.getHeadLineStyle2(isDarkMode)
                                  .copyWith(fontSize: 64)),
                        ],
                        if (_controller.state.showContinue)
                          const PulsingEffect(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
