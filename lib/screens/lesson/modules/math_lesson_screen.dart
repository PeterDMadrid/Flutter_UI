import 'dart:math';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gif/gif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/lesson_controller.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/screens/lesson/widgets/intro_text.dart';
import 'package:flutter_hands/base/res/animations/pulsing_effect.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;

class MathLessonScreen extends StatefulWidget {
  const MathLessonScreen({super.key, required this.name});

  final String name;

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
  late final GifController _teacherController;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsEnabled = true;
  bool _isInitializing = true;
  bool _currentTextSpeaking = false;

  @override
  void initState() {
    super.initState();
    _controller = LessonController(
        setState: setState,
        numberSequences: _numberSequences,
        onLastContinueTapped: () {
          twoDigit = false;
          isSubtraction = true;
          generateNumberForSubtraction();
          _updateMathLessonProgress(); // This will generate a new number and update the state
        },
        goBackToLessonScreen: () {
          Navigator.pop(context, true);
        });
    _random = Random();

    generateNumberforAddition();

    _firstGifController = GifController(vsync: this);
    _firstGifController.addListener(_handleFirstGifCompletion);
    _secondGifController = GifController(vsync: this);
    _secondGifController.addListener(_handleSecondGifCompletion);
    _teacherController = GifController(vsync: this);
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.0);

    _initializeVoice().then((_) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    });
  }

  void _goBackToLessonScreen() {
    // Return a result to indicate that the LessonScreen should refresh
    Navigator.pop(context, true);
    print("got back to lesson screen");
  }

  static const _storage = FlutterSecureStorage();
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> _updateMathLessonProgress() async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(
            'http://${GlobalVariables.server}/api/auth/update-math-lesson-progress/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token', // Adjust based on your auth method
        },
      );

      if (response.statusCode == 200) {
        print('Math Lesson progress updated successfully');
      } else {
        print('Failed to update introduction progress: ${response.body}');
      }
    } catch (e) {
      print('Error updating introduction progress: $e');
    }
  }

  Future<void> _initializeVoice() async {
    try {
      // only print when selecting voice
      // List<dynamic> voices = await _flutterTts.getVoices;
      // for (var voice in voices) {
      //   print(voice);
      // }
      await _flutterTts.setVoice({
        'name': 'Google UK English Female',
        'locale': 'en-GB',
      });
      // Optional: add a small delay to ensure voice settings are applied
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      print('Error initializing TTS voice: $e');
    }
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
      num = _random.nextInt(9) + 1;
      subtrahend = _random.nextInt(num + 1);
      digits = num.toString() + subtrahend.toString();
      difference = num - subtrahend;
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

  Widget _buildGifDisplayForAddition(isDarkMode) {
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
            child: Text("+", style: AppStyles.getHeadLineStyle2(isDarkMode)),
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

  Widget _buildTextSequence(isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(_controller.state.currentTextIndex + 1, (i) {
        final isCurrentText = i == _controller.state.currentTextIndex;
        if (_isTtsEnabled &&
            isCurrentText &&
            !_controller.state.showGif &&
            !_currentTextSpeaking) {
          _currentTextSpeaking = true;
          _flutterTts
              .speak(_processText(_controller.state.currentTexts[i].text));
        }
        return Padding(
          padding: EdgeInsets.only(bottom: isCurrentText ? 0 : 20),
          child: ReadingEffect(
            text: _processText(_controller.state.currentTexts[i].text),
            style: isCurrentText
                ? AppStyles.getHeadLineStyle2(isDarkMode)
                : isDarkMode
                    ? AppStyles.headLineStyle2.copyWith(color: Colors.white54)
                    : AppStyles.lightHeadLineStyle2
                        .copyWith(color: const Color.fromARGB(137, 17, 17, 17)),
            speed: 75,
            animate: isCurrentText,
            onAnimationComplete: isCurrentText
                ? () => setState(() => _controller.state.showContinue = true)
                : null,
          ),
        );
      }),
    );
  }

  void _toggleTts() {
    setState(() {
      _isTtsEnabled = !_isTtsEnabled;
    });
    if (!_isTtsEnabled) {
      _flutterTts.stop();
    }
  }

  void _stopSpeech() {
    if (!_controller.state.showContinue) {
      return;
    }
    _flutterTts.stop();
  }

  void _setSpeakingDefault() {
    if (!_controller.state.showContinue) {
      return;
    }
    _currentTextSpeaking = false;
  }

  @override
  Widget build(BuildContext context) {
    double teacherSize = MediaQuery.of(context).size.width * 1;
    if (_isInitializing) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          _goBackToLessonScreen();
        },
        child: ValueListenableBuilder(
            valueListenable: ThemeManager().isDarkModeNotifier,
            builder: (context, isDarkMode, child) {
              return Scaffold(
                backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
                appBar: AppBar(
                  backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
                  iconTheme: IconThemeData(
                      color: isDarkMode ? Colors.white : Colors.black87),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: _goBackToLessonScreen,
                  ),
                ),
                body: Center(
                  child: CircularProgressIndicator(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              );
            }),
      );
    }
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _goBackToLessonScreen();
      },
      child: ValueListenableBuilder(
          valueListenable: ThemeManager().isDarkModeNotifier,
          builder: (context, isDarkMode, child) {
            return Scaffold(
                appBar: AppBar(
                  backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
                  iconTheme: IconThemeData(
                      color: isDarkMode ? Colors.white : Colors.black87),
                  actions: [
                    IconButton(
                      icon: Icon(
                        _isTtsEnabled ? Icons.volume_up : Icons.volume_off,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onPressed: _toggleTts,
                    ),
                  ],
                ),
                backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
                body: GestureDetector(
                  onTap: () {
                    _stopSpeech();
                    _setSpeakingDefault();
                    _controller.handleTap();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Stack(children: [
                    SafeArea(
                        child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        _buildTextSequence(isDarkMode),
                        const SizedBox(height: 35),
                        if (_controller.state.showGif)
                          SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                  child:
                                      _buildGifDisplayForAddition(isDarkMode))),
                        if (_controller.state.showContinue)
                          const PulsingEffect(),
                      ],
                    )),
                    Positioned(
                      right: -140,
                      bottom: -40,
                      child: SizedBox(
                        width: teacherSize,
                        height: teacherSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(200),
                          child: !_controller.state.showGif
                              ? (!_controller.state.showContinue
                                  ? Gif(
                                      image:
                                          const AssetImage(AppMedia.teacherGif),
                                      autostart: Autostart.loop,
                                      controller: _teacherController,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      AppMedia.teacherRest,
                                      fit: BoxFit.cover,
                                    ))
                              : Image.asset(
                                  AppMedia.teacherRest,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ).animate(
                      target: _controller.state.showGif ? 1 : 0,
                      effects: [
                        const ScaleEffect(
                          begin: Offset(1, 1),
                          end: Offset(0.6, 0.6),
                          duration: Duration(milliseconds: 500),
                        ),
                        const MoveEffect(
                          begin: Offset(0, -50),
                          end: Offset(0, 100),
                          duration: Duration(milliseconds: 500),
                        ),
                      ],
                    )
                  ]),
                ));
          }),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _firstGifController.removeListener(_handleFirstGifCompletion);
    _secondGifController.removeListener(_handleSecondGifCompletion);

    _firstGifController.dispose();
    _secondGifController.dispose();

    _teacherController.dispose();

    super.dispose();
  }
}
