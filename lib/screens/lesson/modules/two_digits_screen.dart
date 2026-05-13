import 'dart:math';
import 'dart:async';
import 'package:flutter_hands/base/widgets/number_selection.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gif/gif.dart';
import '../widgets/intro_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/lesson_controller.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';
import 'package:flutter_hands/base/res/animations/pulsing_effect.dart';
import 'package:flutter_hands/screens/lesson/widgets/digit_animation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/base/res/global/global_variables.dart';

class TwoDigitsScreen extends StatefulWidget {
  const TwoDigitsScreen({super.key, required this.name});

  final String name;

  @override
  State<TwoDigitsScreen> createState() => _TwoDigitsScreenState();
}

class _TwoDigitsScreenState extends State<TwoDigitsScreen>
    with TickerProviderStateMixin {
  // Constants
  static const double _defaultPadding = 16.0;
  static const double _gifSpacing = 35.0;
  static const double _digitSpacing = 5.0;
  static const int _animationSpeed = 75;

  // State variables
  int _currentGif = 0;
  String _numberString;
  bool _isResetting = false;

  late final LessonController _controller;
  late final GifController _gifController;
  late final GifController _teacherController;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsEnabled = true;
  bool _isInitializing = true;
  bool _currentTextSpeaking = false;
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

    _gifController = GifController(vsync: this)
      ..addListener(_handleGifCompletion);
    ;
    _gifController.addListener(_handleGifCompletion);

    _teacherController = GifController(vsync: this);
    //tts
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

  Future<void> _updateTwoDigitsProgress() async {
    try {
      final token = await getToken();
      final response = await http.post(
        Uri.parse(
            'http://${GlobalVariables.server}/api/auth/update-two-digits-progress/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token', // Adjust based on your auth method
        },
      );

      if (response.statusCode == 200) {
        print('Two Digits progress updated successfully');
      } else {
        print('Failed to update Two Digits progress: ${response.body}');
      }
    } catch (e) {
      print('Error updating Two Digits progress: $e');
    }
  }

  Future<void> _initializeVoice() async {
    try {
      // only print if seelcting voice
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

  @override
  void dispose() {
    _flutterTts.stop();
    _gifController.removeListener(_handleGifCompletion);
    _gifController.dispose();
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

  // At class level
  final List<String> _recentNumbers = [];
  final int _maxRecentHistory = 10;

  void generateNumber() {
    setState(() {
      _isResetting = true;
      submitted = false;
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

  bool submitted = false;

  void _handleGifCompletion() {
    if (_isResetting) return;

    if (_numberString[0] == _numberString[1]) {
      _controller.state.showContinue = true;
      if (!submitted) {
        _updateTwoDigitsProgress();
        submitted = true;
      }
    } else if (_gifController.isCompleted) {
      setState(() {
        if (_currentGif < 1) {
          _currentGif++;
          _gifController.reset();
        } else {
          _restartGif();
          _controller.state.showContinue = true;
          _updateTwoDigitsProgress();
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
          if (_isTtsEnabled &&
              isCurrentText &&
              !_controller.state.showGif &&
              !_currentTextSpeaking) {
            _currentTextSpeaking = true;
            _flutterTts.awaitSpeakCompletion(true);
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
                body: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        _stopSpeech();
                        _setSpeakingDefault();
                        _controller.handleTap();
                      },
                      behavior: HitTestBehavior.translucent,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          SafeArea(
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
                                      style: AppStyles.getHeadLineStyle2(
                                              isDarkMode)
                                          .copyWith(fontSize: 64)),
                                ],
                                if (_controller.state.showContinue)
                                  const PulsingEffect(),
                              ],
                            ),
                          ),
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Opacity(
                              opacity: _controller.state.showGif ? 1.0 : 0.5,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: AbsorbPointer(
                                  absorbing: !_controller.state.showGif,
                                  child: NumberSelection(
                                    isTwoDigit: true,
                                    onNumberSelected: (number) {
                                      if (number >= 11 && number <= 99) {
                                        setState(() {
                                          submitted = false;
                                          _currentTextSpeaking = false;
                                          _numberString = number.toString();
                                          _currentGif = 0;
                                          _gifController.reset();
                                          _isResetting = true;
                                          _recentNumbers.add(_numberString);
                                          if (_recentNumbers.length >
                                              _maxRecentHistory) {
                                            _recentNumbers.removeAt(0);
                                          }
                                          Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () {
                                            if (mounted) {
                                              setState(() {
                                                _isResetting = false;
                                                _controller.state.showContinue =
                                                    false;
                                              });
                                            }
                                          });
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
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
                                            image: const AssetImage(
                                                AppMedia.teacherGif),
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
                  ],
                ));
          }),
    );
  }
}
