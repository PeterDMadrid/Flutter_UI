import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/widgets/snackbar.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/widgets/instructions.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/base/widgets/next_question_button.dart';
import 'package:flutter_hands/controllers/recognition_controller.dart';
import 'package:flutter_hands/screens/practice/widgets/choice_card.dart';
import 'package:vibration/vibration.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  late RecognitionController _controller;
  OverlayEntry? _overlayEntry;
  bool _isAnswerLocked = false;
  int? _selectedChoice;
  bool _showResult = false;
  bool _showNextButton = false;

  static const _storage = FlutterSecureStorage();

  //Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  final String instructions =
      "Get ready to familiarize yourself with sign language!";

  final String bottomInstructions =
      "Observe the signed number. Then, choose the correct answer. Let's begin!";

  @override
  void initState() {
    super.initState();
    _controller = RecognitionController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
    _initializeAudioPlayer();
  }

  void _showInstructions() {
    _overlayEntry = OverlayEntry(
      builder: (context) => Instructions(
          onGotIt: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
          instructionContent: instructions,
          bottomInstruction: bottomInstructions,
          images: const [
            'assets/instructions/recognition_instruction_1.jpg',
            'assets/instructions/recognition_instruction_2.jpg',
          ],
          gifInstruction: AppMedia.practiceTeacherGif),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint("AudioPlayer initialization error: $e");
    }
  }

  void _handleAnswer(int selectedChoice) async {
    if (_isAnswerLocked) return;
    final isCorrect = _controller.checkAnswer(selectedChoice);
    String message = isCorrect ? 'Correct!' : 'Incorrect!';
    if (isCorrect) {
      Vibration.vibrate(duration: 500);
      await _audioPlayer.play(AssetSource(AppMedia.correctSound));
    } else {
      Vibration.vibrate(duration: 1000);
      await _audioPlayer.play(AssetSource(AppMedia.incorrectSound));
    }
    setState(() {
      showCustomSnackBar(context, isCorrect, message);
      _isAnswerLocked = true;
      _selectedChoice = selectedChoice;
      _showResult = true;
      _showNextButton = true;
    });
  }

  void _handleNext(isDarkMode) {
    setState(() {
      if (!_controller.isQuizFinished) {
        _controller.nextQuestion();
        _selectedChoice = null;
        _showResult = false;
        _showNextButton = false;
        _isAnswerLocked = false;
      } else {
        _showResults(isDarkMode);
      }
    });
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  void _showResults(isDarkMode) async {
    await _sendRecognitionScoreToAPI(_controller.score);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
        title: Text(
          'Quiz Complete!',
          style: AppStyles.getHeadLineStyle2(isDarkMode),
        ),
        content: Text(
          'Your score: ${_controller.score}/${RecognitionController.totalQuestions}',
          style: AppStyles.getParagraph1(isDarkMode),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: AppStyles.getHeadLineStyle1(isDarkMode)
                  .copyWith(color: AppStyles.buttonColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRecognitionScoreToAPI(int score) async {
    String apiUrl =
        'http://${GlobalVariables.server}/api/auth/save_recognition_score/';
    final token = await getToken();
    final userData = await AuthService.getUserData();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'username': userData?['username'],
          'recognition_score': score,
        }),
      );

      if (response.statusCode == 200) {
        print('Recognition score saved successfully: ${response.body}');
      } else {
        throw Exception(
            'Failed to save recognition score: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving recognition score: $e');
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final currentQuestion =
        _controller.questions[_controller.currentQuestionIndex];
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Recognition Practice'),
              backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
              foregroundColor: AppStyles.getTextColor(isDarkMode),
            ),
            body: Container(
              decoration: BoxDecoration(
                  color: AppStyles.getBackgroundColor(isDarkMode)),
              height: screenHeight,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Question ${_controller.currentQuestionIndex + 1}/${RecognitionController.totalQuestions}',
                      style: AppStyles.getHeadLineStyle2(isDarkMode),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Center(
                    child: Text(
                      currentQuestion.correctNumber.toString(),
                      style: AppStyles.getHeadLineStyle1(isDarkMode)
                          .copyWith(fontSize: 80),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: GridView.count(
                            crossAxisSpacing: 2.0,
                            mainAxisSpacing: 2.0,
                            crossAxisCount: 2,
                            childAspectRatio: 1,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: currentQuestion.choices.map((choice) {
                              return ChoiceCard(
                                choice: choice.toString(),
                                onPressed: _isAnswerLocked
                                    ? () {}
                                    : () => _handleAnswer(choice),
                                isSelected: _selectedChoice == choice,
                                isCorrect:
                                    currentQuestion.correctNumber == choice,
                                showResult: _showResult,
                              );
                            }).toList(),
                          ),
                        ),
                        if (_showNextButton) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 60),
                            child: NextQuestionButton(
                                text: "Next Question",
                                onPressed: () => _handleNext(isDarkMode)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
