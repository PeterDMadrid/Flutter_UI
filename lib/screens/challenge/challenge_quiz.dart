import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/widgets/phrases.dart';
import 'package:gif/gif.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/main.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/widgets/snackbar.dart';
import 'package:flutter_hands/base/widgets/instructions.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/widgets/camera_controls.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/base/widgets/next_question_button.dart';
import 'package:flutter_hands/services/image_prediction_service.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';
import 'package:flutter_hands/base/widgets/handsigns_camera_preview.dart';
import 'package:flutter_hands/screens/challenge/widgets/mode_button.dart';
import 'package:flutter_hands/screens/challenge/widgets/answer_display.dart';
import 'package:flutter_hands/controllers/challenge_quiz_controller.dart.dart';

class ChallengeQuiz extends StatefulWidget {
  const ChallengeQuiz({super.key});

  @override
  State<ChallengeQuiz> createState() => _ChallengeQuizState();
}

class _ChallengeQuizState extends State<ChallengeQuiz>
    with TickerProviderStateMixin {
  late ChallengeQuizController _quizController;
  late dynamic difficulty;
  late MathMode mode;

  OverlayEntry? _overlayEntry;
  CameraController? _cameraController;
  bool _isFrontCamera = false;
  String _errorMessage = '';
  bool _isInitialized = false;
  bool _showNextButton = false;

  late List<int> currentAnswer = [];
  bool _isProcessing = false;
  int _prediction = -1;
  String _label = '';
  String _handedness = '';
  double _confidence = 0.0;

  int _score = 0;

  bool showGif = false;
  late final GifController _teacherController;
  bool _lastAnswerCorrect = false;

  String get instructions =>
      "Time to practice ${mode == MathMode.addition ? 'addition' : 'subtraction'} with sign language!";

  final String bottomInstructions =
      "Solve the equation and sign your answer. Capture once you're ready!";

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeAudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
    Future.delayed(Duration.zero, () {
      Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      mode = args['mode'] as MathMode;
      if (mode == MathMode.addition) {
        difficulty = args['difficulty'] as AdditionDifficulty;
      } else {
        difficulty = args['difficulty'] as SubtractionDifficulty;
      }

      _quizController = ChallengeQuizController(
        difficulty: difficulty,
        mode: mode,
      );
      _initializeLevel();
      setState(() {});
    });
    _teacherController = GifController(vsync: this);
  }

  File? _capturedImageFile;
  bool _showCapturedImage = false;

  Future<void> _captureAndPredict(isDarkMode) async {
    if (_isProcessing ||
        _cameraController == null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile image = await _cameraController!.takePicture();

      // Add a timeout to prevent indefinite waiting
      final prediction =
          await ImagePredictionService.sendImageToAPI(File(image.path))
              .timeout(const Duration(seconds: 5), onTimeout: () {
        // Return a default value indicating no hand detected
        return {
          'prediction': -1,
          'label': 'No hand detected',
          'confidence': 0.0,
          'handedness': 'Unknown'
        };
      });

      setState(() {
        _prediction = prediction['prediction'] ?? -1;
        _label = prediction['label'] ?? 'Unknown';
        _confidence = prediction['confidence']?.toDouble() ?? 0.0;
        _handedness = prediction['handedness'] ?? 'Unknown';
        _isProcessing = false;
      });

      if (_prediction >= 0 && mounted) {
        setState(() {
          final currentQuestion =
              _quizController.questions[_quizController.currentQuestionIndex];
          final expectedLength =
              currentQuestion.correctAnswer.toString().length;

          if (expectedLength == 1) {
            // For single-digit answers (easy mode)
            currentAnswer.add(_prediction);
            _handleAnswer([currentAnswer[0]], isDarkMode);
            _capturedImageFile = File(image.path);
            _showCapturedImage = true;
          } else {
            // For double-digit answers (medium/hard mode)
            if (currentAnswer.isEmpty) {
              currentAnswer.add(_prediction);
            } else if (currentAnswer.length == 1) {
              currentAnswer.add(_prediction);
              _handleAnswer(currentAnswer, isDarkMode);
              _capturedImageFile = File(image.path);
              _showCapturedImage = true;
            }
          }
        });
      } else {
        setState(() {
          _showCapturedImage = false;
          _capturedImageFile = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hand detected. Please try again.')),
        );
      }

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _showCapturedImage = false;
        _capturedImageFile = null;
      });
    }
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.release);
    } catch (e) {
      debugPrint("AudioPlayer initialization error: $e");
    }
  }

  Future<void> _handleAnswer(List handSign, isDarkMode) async {
    final isCorrect = _quizController.checkAnswer(handSign);
    _lastAnswerCorrect = isCorrect;
    final currentQuestion =
        _quizController.questions[_quizController.currentQuestionIndex];
    final correctAnswer =
        currentQuestion.correctAnswer; // Get the correct answer

    if (isCorrect) {
      _score++;
      Vibration.vibrate(duration: 500);
      await _audioPlayer.play(AssetSource(AppMedia.correctSound));
    } else {
      Vibration.vibrate(duration: 1000);
      await _audioPlayer.play(AssetSource(AppMedia.incorrectSound));
    }

    setState(() {
      showGif = true;
      _showNextButton = true;
      _isProcessing = false;
    });

    // Create the SnackBar message
    String message = isCorrect
        ? 'Correct!'
        : 'Incorrect! The correct answer is $correctAnswer.';
    showCustomSnackBar(context, isCorrect, message);
  }

  void _handleNext(isDarkMode) {
    setState(() {
      _showCapturedImage = false;
      _capturedImageFile = null;

      if (!_quizController.isQuizFinished) {
        _quizController.nextQuestion();
        _isProcessing = false;
        currentAnswer.clear();
        _showNextButton = false;
        showGif = false;
      } else {
        _showResults(isDarkMode);
        showGif = false;
      }
    });
  }

  void _clearAnswer() {
    setState(() {
      currentAnswer.clear();
    });
  }

  Future<void> _initializeCamera() async {
    if (globalCameras.isEmpty) {
      setState(() {
        _errorMessage = 'No cameras found';
      });
      return;
    }

    await _cameraController?.dispose();

    final controller = CameraController(
      globalCameras[_isFrontCamera && globalCameras.length > 1 ? 0 : 1],
      ResolutionPreset.ultraHigh,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await controller.initialize();

      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isInitialized = true;
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error initializing camera: $e';
        _isInitialized = false;
      });
    }
  }

  void _toggleCamera() async {
    if (globalCameras.length < 2) return;

    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitialized = false;
    });

    await _initializeCamera();
  }

  void _showResults(isDarkMode) {
    _sendChallengeScoreToAPI(_score);

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
          'Your score: $_score/${_quizController.totalQuestions}',
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

  static const _storage = FlutterSecureStorage();
  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> _sendChallengeScoreToAPI(int score) async {
    String apiUrl =
        'http://${GlobalVariables.server}/api/auth/save_challenge_score/';
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
          'score': score,
          'level': level, // This is already defined in your class
        }),
      );

      if (response.statusCode == 200) {
        print('Challenge score saved successfully: ${response.body}');
      } else {
        throw Exception(
            'Failed to save challenge score: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving challenge score: $e');
    }
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
        gifInstruction: AppMedia.practiceTeacherGif,
        images: mode == MathMode.addition
            ? const [
                "assets/instructions/challenge_instruction_addition_1.JPG",
                "assets/instructions/challenge_instruction_addition_2.JPG",
                "assets/instructions/challenge_instruction_addition_3.JPG",
              ]
            : const [
                "assets/instructions/challenge_instruction_subtraction_1.JPG",
                "assets/instructions/challenge_instruction_subtraction_2.JPG",
                "assets/instructions/challenge_instruction_subtraction_3.JPG",
              ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  late int level;
  void _initializeLevel() {
    final levelMap = {
      AdditionDifficulty.additionLevel1: 1,
      AdditionDifficulty.additionLevel2: 2,
      AdditionDifficulty.additionLevel3: 3,
      AdditionDifficulty.additionLevel4: 4,
      AdditionDifficulty.additionLevel5: 5,
      AdditionDifficulty.additionLevel6: 6,
      SubtractionDifficulty.subtractionLevel1: 7,
      SubtractionDifficulty.subtractionLevel2: 8,
      SubtractionDifficulty.subtractionLevel3: 9,
      SubtractionDifficulty.subtractionLevel4: 10,
      SubtractionDifficulty.subtractionLevel5: 11,
      SubtractionDifficulty.subtractionLevel6: 12,
    };
    level = mode == MathMode.addition
        ? levelMap[difficulty as AdditionDifficulty] ?? 1
        : levelMap[difficulty as SubtractionDifficulty] ?? 7;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _cameraController?.dispose();
    _audioPlayer.dispose();
    _teacherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double teacherSize = MediaQuery.of(context).size.width * 0.7;
    final currentQuestion =
        _quizController.questions[_quizController.currentQuestionIndex];
    final expectedLength = currentQuestion.correctAnswer.toString().length;

    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                  '${mode == MathMode.addition ? 'Addition' : 'Subtraction'} Challenge - ${difficulty.name.toUpperCase()}'),
              backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
              foregroundColor: AppStyles.getTextColor(isDarkMode),
            ),
            body: _buildBody(screenHeight, currentQuestion, expectedLength,
                isDarkMode, teacherSize),
          );
        });
  }

  Widget _buildBody(double screenHeight, final currentQuestion,
      int expectedLength, isDarkMode, teacherSize) {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration:
                BoxDecoration(color: AppStyles.getBackgroundColor(isDarkMode)),
            height: screenHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Question ${_quizController.currentQuestionIndex + 1}/${_quizController.totalQuestions}',
                    style: AppStyles.getHeadLineStyle2(isDarkMode),
                  ),
                ),
                SizedBox(height: screenHeight * 0.010),
                Center(
                    child: Text(
                  'What is ${currentQuestion.toString()}',
                  style: AppStyles.getHeadLineStyle1(isDarkMode),
                )),
                SizedBox(height: screenHeight * 0.025),
                Stack(children: [
                  HandSignCameraPreview(
                    isFrontCamera: _isFrontCamera,
                    cameraController: _cameraController,
                    capturedImageFile: _capturedImageFile,
                    showCapturedImage: _showCapturedImage,
                  ),
                  Positioned(
                    bottom: 30,
                    left: 0,
                    right: 0,
                    child: Align(
                      alignment: Alignment.center,
                      child: AnswerDisplay(
                        currentAnswer: currentAnswer,
                        expectedLength: expectedLength,
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
          if (!_showNextButton)
            CameraControls(
              onCapture:
                  _isProcessing ? () {} : () => _captureAndPredict(isDarkMode),
              onToggleCamera: _toggleCamera,
              isProcessing: _isProcessing,
            ),
          //teacher
          if (showGif) ...[
            Positioned(
                    right: -120,
                    bottom: 40,
                    child: SizedBox(
                      width: teacherSize,
                      height: teacherSize,
                      child: !showGif
                          ? Image.asset(
                              AppMedia.practiceTeacherRest,
                              fit: BoxFit.cover,
                            )
                          : Gif(
                              image:
                                  const AssetImage(AppMedia.practiceTeacherGif),
                              autostart: Autostart.loop,
                              controller: _teacherController,
                              fit: BoxFit.contain),
                    ))
                .animate()
                .slideX(
                    begin: 0.5,
                    end: 0,
                    duration: 500.ms,
                    curve: Curves.easeInBack)
                .slideX(
                    begin: 0,
                    end: 0.5,
                    duration: 500.ms,
                    curve: Curves.easeInBack,
                    delay: 3200.ms),
            //dialog box
            Positioned(
              left: 0,
              right: 0,
              bottom: 150,
              child: Opacity(
                opacity: 0.8,
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: teacherSize,
                    height: teacherSize,
                    child: Stack(
                      children: [
                        Image.asset(
                          _lastAnswerCorrect
                              ? AppMedia.teacherDialog
                              : AppMedia.wrongTeacherDialog,
                          fit: BoxFit.contain,
                        ),
                        Align(
                          alignment: const Alignment(-0.1, -0.7),
                          child: Text(
                            _lastAnswerCorrect
                                ? positivePhrases[
                                    _quizController.currentQuestionIndex %
                                        positivePhrases.length]
                                : negativePhrases[
                                    _quizController.currentQuestionIndex %
                                        negativePhrases.length],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
                .animate()
                .slide(
                  begin: const Offset(1, 1),
                  end: const Offset(0, 0),
                  duration: 500.ms,
                  curve: Curves.easeInBack,
                )
                .slide(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 750.ms,
                  curve: Curves.easeInBack,
                  delay: 3200.ms,
                ),
          ],
          if (currentAnswer.isNotEmpty && !_showNextButton)
            Positioned(
                bottom: 60,
                right: 40,
                child: FloatingActionButton(
                  backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
                  foregroundColor: AppStyles.getTextColor(isDarkMode),
                  onPressed: currentAnswer.isNotEmpty ? _clearAnswer : null,
                  child: const Icon(Icons.backspace_sharp),
                )),
          if (_showNextButton)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: NextQuestionButton(
                    text: "Next Question",
                    onPressed: () => _handleNext(isDarkMode)),
              ),
            ),
        ],
      ),
    );
  }
}
