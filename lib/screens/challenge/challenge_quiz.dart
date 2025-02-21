import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/main.dart';
import 'package:flutter_hands/base/widgets/instructions.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/widgets/camera_controls.dart';
import 'package:flutter_hands/services/image_prediction_service.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';
import 'package:flutter_hands/screens/challenge/widgets/mode_button.dart';
import 'package:flutter_hands/screens/challenge/widgets/answer_display.dart';
import 'package:flutter_hands/controllers/challenge_quiz_controller.dart.dart';

class ChallengeQuiz extends StatefulWidget {
  const ChallengeQuiz({super.key});

  @override
  State<ChallengeQuiz> createState() => _ChallengeQuizState();
}

class _ChallengeQuizState extends State<ChallengeQuiz> {
  late ChallengeQuizController _quizController;
  late Difficulty difficulty;
  late MathMode mode;

  OverlayEntry? _overlayEntry;
  CameraController? _cameraController;
  bool _isFrontCamera = false;
  String _errorMessage = '';
  bool _isInitialized = false;

  late List<int> currentAnswer = [];
  bool _isProcessing = false;
  int _prediction = -1;
  String _label = '';
  String _handedness = '';
  double _confidence = 0.0;

  int _score = 0;

  String get instructions =>
      "Time to practice ${mode == MathMode.addition ? 'addition' : 'subtraction'} with sign language!";

  final String bottomInstructions =
      "Solve the equation and sign your answer. Capture once you're ready!";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
    Future.delayed(Duration.zero, () {
      Map<String, dynamic> args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      mode = args['mode'] as MathMode;
      difficulty = args['difficulty'] as Difficulty;

      _quizController = ChallengeQuizController(
        difficulty: difficulty,
        mode: mode,
      );

      setState(() {});
    });
  }

  Future<void> _captureAndPredict() async {
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

      final prediction =
          await ImagePredictionService.sendImageToAPI(File(image.path));

      setState(() {
        _prediction = prediction['prediction'] ?? 401;
        _label = prediction['label'] ?? 'Unknown';
        _confidence = prediction['confidence']?.toDouble() ?? 0.0;
        _handedness = prediction['handedness'] ?? 'Unknown';
      });

      if (_prediction != 401 && mounted) {
        setState(() {
          final currentQuestion =
              _quizController.questions[_quizController.currentQuestionIndex];
          final expectedLength =
              currentQuestion.correctAnswer.toString().length;

          if (expectedLength == 1) {
            // For single-digit answers (easy mode)
            currentAnswer.add(_prediction);
            _handleAnswer([currentAnswer[0]]); // Send only the first digit
          } else {
            // For double-digit answers (medium/hard mode)
            if (currentAnswer.isEmpty) {
              currentAnswer.add(_prediction);
            } else if (currentAnswer.length == 1) {
              currentAnswer.add(_prediction);
              _handleAnswer(currentAnswer);
            }
          }
        });
      }

      setState(() {
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _handleAnswer(List handSign) {
    final isCorrect = _quizController.checkAnswer(handSign);
    final currentQuestion = _quizController.questions[_quizController.currentQuestionIndex];
    final correctAnswer = currentQuestion.correctAnswer; // Get the correct answer

    if (isCorrect) {
      _score++;
    }

    // Create the SnackBar message
    String message = isCorrect ? 'Correct!' : 'Incorrect! The correct answer is $correctAnswer.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3), // Increased duration for better visibility
        behavior: SnackBarBehavior.floating,
        backgroundColor: isCorrect ? Colors.teal : Colors.red,
        margin: const EdgeInsets.all(50),
        elevation: 30,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (!_quizController.isQuizFinished) {
          _isProcessing = false;
          _quizController.nextQuestion();
          currentAnswer.clear();
        } else {
          _showResults();
        }
      });
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

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppStyles.backgroundColor,
        title: Text(
          'Quiz Complete!',
          style: AppStyles.headLineStyle2,
        ),
        content: Text(
          'Your score: $_score/${_quizController.totalQuestions}',
          style: AppStyles.paragraph1,
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
              style: AppStyles.headLineStyle1
                  .copyWith(color: AppStyles.buttonColor),
            ),
          ),
        ],
      ),
    );
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

  @override
  void dispose() {
    _overlayEntry?.remove();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final currentQuestion =
        _quizController.questions[_quizController.currentQuestionIndex];
    final expectedLength = currentQuestion.correctAnswer.toString().length;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('${mode == MathMode.addition ? 'Addition' : 'Subtraction'} Challenge - ${difficulty.name.toUpperCase()}'),
        backgroundColor: AppStyles.backgroundColor,
        foregroundColor: AppStyles.textColor,
      ),
      body: _buildBody(screenHeight, currentQuestion, expectedLength),
    );
  }

  Widget _buildBody(
      double screenHeight, final currentQuestion, int expectedLength) {
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
            decoration: BoxDecoration(color: AppStyles.backgroundColor),
            height: screenHeight,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Question ${_quizController.currentQuestionIndex + 1}/${_quizController.totalQuestions}',
                    style: AppStyles.headLineStyle2,
                  ),
                ),
                SizedBox(height: screenHeight * 0.010),
                Center(
                    child: Text(
                  'What is ${currentQuestion.toString()}',
                  style: AppStyles.headLineStyle1,
                )),
                SizedBox(height: screenHeight * 0.025),
                _buildCameraPreview(),
                SizedBox(height: screenHeight * 0.025),
                AnswerDisplay(
                  currentAnswer: currentAnswer,
                  expectedLength: expectedLength,
                ),
              ],
            ),
          ),
          CameraControls(
            onCapture: _isProcessing ? () {} : _captureAndPredict,
            onToggleCamera: _toggleCamera,
            isProcessing: _isProcessing,
          ),
          if (currentAnswer.isNotEmpty)
            Positioned(
                bottom: 30,
                right: 40,
                child: FloatingActionButton(
                  backgroundColor: AppStyles.backgroundColor,
                  foregroundColor: AppStyles.textColor,
                  onPressed: currentAnswer.isNotEmpty ? _clearAnswer : null,
                  child: const Icon(Icons.backspace_sharp),
                ))
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 64.0),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: ClipRect(
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }
}
