import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:gif/gif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/widgets/number_selection.dart';
import 'package:flutter_hands/controllers/lesson_controller.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/screens/lesson/widgets/intro_text.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';
import 'package:flutter_hands/base/res/animations/pulsing_effect.dart';
import 'package:flutter_hands/screens/lesson/widgets/gif_display.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Introduction extends StatefulWidget {
  const Introduction({super.key, required this.name});

  final String name;

  @override
  State<Introduction> createState() => _IntroductionState();
}

class _IntroductionState extends State<Introduction>
    with TickerProviderStateMixin {
  late final LessonController _controller;
  late final GifController _teacherController;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsEnabled = true;
  bool _isVoiceInitialized = false;
  bool _isInitializing = true;
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

  void _goBackToLessonScreen() {
    // Return a result to indicate that the LessonScreen should refresh
    Navigator.pop(context, true);
    print("got back to lesson screen");
  }

  static const _storage = FlutterSecureStorage();
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> _updateIntroProgress() async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(
            'http://${GlobalVariables.server}/api/auth/update-intro-progress/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token', // Adjust based on your auth method
        },
      );

      if (response.statusCode == 200) {
        print('Introduction progress updated successfully');
      } else {
        print('Failed to update introduction progress: ${response.body}');
      }
    } catch (e) {
      print('Error updating introduction progress: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(1);
    _flutterTts.setPitch(1.0);

    _initializeVoice().then((_) {
      // Only set up the controller after voice is initialized
      _controller = LessonController(
        setState: setState,
        numberSequences: _numberSequences,
      );
      _teacherController = GifController(vsync: this);

      // Force a rebuild after everything is initialized
      if (mounted)
        setState(() {
          _isVoiceInitialized = true;
          _isInitializing = false;
        });
    });
  }

  Future<void> _initializeVoice() async {
    try {
      List<dynamic> voices = await _flutterTts.getVoices;
      for (var voice in voices) {
        print(voice);
      }
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

  String _processText(String text) {
    return text.replaceAll('%name%', widget.name);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _teacherController.dispose();
    super.dispose();
  }

  void _toggleTts() {
    setState(() {
      _isTtsEnabled = !_isTtsEnabled;
    });
    if (!_isTtsEnabled) {
      _flutterTts.stop();
    }
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
                  _controller.handleTap();
                  _flutterTts.stop();
                },
                behavior: HitTestBehavior.translucent,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    SafeArea(
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          ...List.generate(
                              _controller.state.currentTextIndex + 1, (i) {
                            final isCurrentText =
                                i == _controller.state.currentTextIndex;
                            if (_isTtsEnabled &&
                                isCurrentText &&
                                !_controller.state.showGif) {
                              _flutterTts.speak(_processText(
                                  _controller.state.currentTexts[i].text));
                            }
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom: isCurrentText ? 0 : 20),
                              child: ReadingEffect(
                                text: _processText(
                                    _controller.state.currentTexts[i].text),
                                style: isCurrentText
                                    ? AppStyles.getHeadLineStyle2(isDarkMode)
                                    : isDarkMode
                                        ? AppStyles.headLineStyle2
                                            .copyWith(color: Colors.white54)
                                        : AppStyles.lightHeadLineStyle2
                                            .copyWith(
                                                color: const Color.fromARGB(
                                                    137, 17, 17, 17)),
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
                                if (_controller.state.currentNumber == 10) {
                                  _updateIntroProgress();
                                }
                              },
                            ),
                          ],
                          if (_controller.state.showContinue)
                            const PulsingEffect(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: NumberSelection(
                        isTwoDigit: false,
                        onNumberSelected: _controller.handleNumberSelection,
                      ),
                    ),
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
                  ],
                ),
              ),
            );
          }),
    );
  }
}
