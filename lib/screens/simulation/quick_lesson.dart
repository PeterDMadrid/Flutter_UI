import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:gif/gif.dart';
import 'package:flutter_tts/flutter_tts.dart';

class QuickLesson extends StatefulWidget {
  const QuickLesson({super.key});

  @override
  State<QuickLesson> createState() => _QuickLessonState();
}

class _QuickLessonState extends State<QuickLesson>
    with TickerProviderStateMixin {
  late final GifController _gifController;
  int _playCount = 0;
  bool _showRetryButton = false;
  int _currentIndex = 0;

  //talktospeech
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitializing = true;
  bool _isSpeaking = false;

  final List<String> numberNames = [
    "Number 0 (Zero)",
    "Number 1 (One)",
    "Number 2 (Two)",
    "Number 3 (Three)",
    "Number 4 (Four)",
    "Number 5 (Five)",
    "Number 6 (Six)",
    "Number 7 (Seven)",
    "Number 8 (Eight)",
    "Number 9 (Nine)",
  ];

  final List<String> instructionsForEachNumber = [
    "To sign zero, touch the tips of your thumb and index finger to form a circle while keeping the other fingers relaxed.",
    "To sign one, raise your index finger while keeping the other fingers folded down.",
    "To sign two, raise your index and middle fingers together, with the rest folded.",
    "To sign three, extend your thumb, index, and middle fingers, folding the ring and pinky fingers.",
    "To sign four, raise four fingers (index to pinky) while keeping your thumb folded across your palm.",
    "To sign five, spread all five fingers wide apart, palm facing forward.",
    "To sign six, touch the tip of your pinky to your thumb, while the other fingers stay extended.",
    "To sign seven, touch the tip of your ring finger to your thumb, with the other fingers extended.",
    "To sign eight, touch the tip of your middle finger to your thumb, keeping the rest extended.",
    "To sign nine, touch the tip of your index finger to your thumb, while the other fingers remain out.",
  ];

  @override
  void initState() {
    super.initState();
    _gifController = GifController(vsync: this);
    _setupGifController();
    _setupTts();
    
    _initializeVoice().then((_) {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
        // Speak the initial instruction when ready
        _speakInstruction();
      }
    });
  }

  void _setupTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(1);
    _flutterTts.setPitch(1.0);

    // Set up TTS completion listener
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
    
    // Handle errors
    _flutterTts.setErrorHandler((error) {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
        print("TTS Error: $error");
      }
    });
  }

  Future<void> _initializeVoice() async {
    try {
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

  Future<void> _speakInstruction() async {
    if (_isInitializing) return;
    
    // Stop any ongoing speech and wait for it to fully stop
    await _flutterTts.stop();
    
    // Small delay to ensure previous speech is fully stopped
    await Future.delayed(const Duration(milliseconds: 100));
    
    setState(() {
      _isSpeaking = true;
    });
    
    // Speak the current instruction
    await _flutterTts.speak(instructionsForEachNumber[_currentIndex]);
  }

  void _setupGifController() {
    _gifController.addListener(() {
      // Check if GIF has completed playing (reached the end)
      if (_gifController.isCompleted && !_showRetryButton) {
        _playCount++;

        if (_playCount < 2) {
          // If played less than twice, restart it
          _gifController.reset();
          _gifController.forward();
        } else {
          // After playing twice, show the retry button
          if (mounted) {
            setState(() {
              _showRetryButton = true;
            });
          }
        }
      }
    });
  }

  Future<void> _retryAnimation() async {
    // If already speaking, stop first
    if (_isSpeaking) {
      await _flutterTts.stop();
      // Short delay to ensure speech has stopped
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    setState(() {
      _showRetryButton = false;
      _playCount = 0;
    });
    
    _gifController.reset();
    _gifController.forward();
    _speakInstruction(); // Speak instruction again when retrying
  }

  Future<void> _goToPrevious() async {
    if (_currentIndex > 0) {
      // If already speaking, stop first
      if (_isSpeaking) {
        await _flutterTts.stop();
        // Short delay to ensure speech has stopped
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      setState(() {
        _currentIndex--;
        _showRetryButton = false;
        _playCount = 0;
      });
      
      _gifController.reset();
      _gifController.forward();
      _speakInstruction(); // Speak the new instruction
    }
  }

  Future<void> _goToNext() async {
    if (_currentIndex < instructionsForEachNumber.length - 1) {
      // If already speaking, stop first
      if (_isSpeaking) {
        await _flutterTts.stop();
        // Short delay to ensure speech has stopped
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      setState(() {
        _currentIndex++;
        _showRetryButton = false;
        _playCount = 0;
      });
      
      _gifController.reset();
      _gifController.forward();
      _speakInstruction(); // Speak the new instruction
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _gifController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeManager().isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return Scaffold(
          backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
          appBar: AppBar(
            title: const Text('Quick Lesson - Simulation'),
            backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
            foregroundColor: AppStyles.getTextColor(isDarkMode),
          ),
          body: buildQuickLesson(isDarkMode),
        );
      },
    );
  }

  Widget buildQuickLesson(bool isDarkMode) {
    final Color buttonColor = isDarkMode ? AppStyles.buttonColor : AppStyles.buttonColor;
    final Color navIconColor = isDarkMode ? AppStyles.textColor : AppStyles.lightTextColor;
    final Color disabledColor = buttonColor.withOpacity(0.4);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(
                  height: 16,
                ),
                Text(
                  numberNames[_currentIndex],
                  style: AppStyles.getHeadLineStyle2(isDarkMode),
                ),
                const SizedBox(height: 16),
                
                // GIF with navigation icons on sides
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Previous button
                    IconButton(
                      onPressed: (_currentIndex > 0 && !_isSpeaking) 
                          ? _goToPrevious 
                          : null,
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        size: 36,
                        color: (_currentIndex > 0 && !_isSpeaking) 
                            ? navIconColor 
                            : navIconColor.withOpacity(0.4),
                      ),
                    ),
                    
                    // GIF container
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Gif(
                          image: AssetImage(AppMedia.handGif[_currentIndex]),
                          autostart: Autostart.once,
                          controller: _gifController,
                        ),
                        if (_showRetryButton)
                          ElevatedButton(
                            onPressed: _isSpeaking ? null : _retryAnimation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: buttonColor.withOpacity(0.9),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              disabledBackgroundColor: disabledColor,
                            ),
                            child: const Text('Retry', 
                                style: TextStyle(fontSize: 16)),
                          ),
                      ],
                    ),
                    
                    // Next button
                    IconButton(
                      onPressed: (_currentIndex < instructionsForEachNumber.length - 1 && !_isSpeaking)
                          ? _goToNext
                          : null,
                      icon: Icon(
                        Icons.arrow_forward_rounded,
                        size: 36,
                        color: (_currentIndex < instructionsForEachNumber.length - 1 && !_isSpeaking) 
                            ? navIconColor 
                            : navIconColor.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Speak button with play/stop capability
                ElevatedButton.icon(
                  onPressed: _isSpeaking 
                      ? () async {
                          await _flutterTts.stop();
                          if (mounted) {
                            setState(() {
                              _isSpeaking = false;
                            });
                          }
                        } 
                      : _speakInstruction,
                  icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                  label: Text(_isSpeaking ? 'Stop Speaking' : 'Speak Instructions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSpeaking ? AppStyles.roseRed : buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ReadingEffect(
            text: instructionsForEachNumber[_currentIndex],
            speed: 75,
            style: AppStyles.getHeadLineStyle2(isDarkMode),
          ),
        ],
      ),
    );
  }
}
