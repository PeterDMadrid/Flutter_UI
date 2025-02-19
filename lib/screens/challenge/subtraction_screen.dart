import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/main.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/widgets/camera_controls.dart';
import 'package:flutter_hands/services/image_prediction_service.dart';
import 'package:flutter_hands/controllers/subtraction_controller.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';
import 'package:flutter_hands/screens/challenge/widgets/answer_display.dart';

class SubtractionScreen extends StatefulWidget {
  const SubtractionScreen({super.key});

  @override
  State<SubtractionScreen> createState() => _SubtractionScreenState();
}

class _SubtractionScreenState extends State<SubtractionScreen> {
  late SubtractionController _subtractionController;
  late Difficulty difficulty;

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

  int _subtractionScore = 0;

  final String instructions =
      """1. Look at the number word on the screen (like "Three").
2. Use your hand to sign the number in front of the camera.
3. Wait for the app to check your sign and give feedback!""";

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
      difficulty = args['difficulty']; // Store the difficulty
      _subtractionController = SubtractionController(difficulty: difficulty);
      setState(() {}); // This will rebuild with the correct difficulty
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
          final currentQuestion = _subtractionController
              .questions[_subtractionController.currentQuestionIndex];
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
    final isCorrect = _subtractionController.checkAnswer(handSign);
    if (isCorrect) {
      _subtractionScore++;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct!' : 'Incorrect!'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isCorrect ? Colors.teal : Colors.red,
        margin: const EdgeInsets.all(50),
        elevation: 30,
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (!_subtractionController.isQuizFinished) {
          _isProcessing = false;
          _subtractionController.nextQuestion();
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
          'Your score: $_subtractionScore/${_subtractionController.totalQuestions}',
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
    final currentQuestion = _subtractionController
        .questions[_subtractionController.currentQuestionIndex];
    final expectedLength = currentQuestion.correctAnswer.toString().length;
    return Scaffold(
      appBar: AppBar(
        title: Text('Subtraction Challenge - ${difficulty.name.toUpperCase()}'),
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
                    'Question ${_subtractionController.currentQuestionIndex + 1}/${_subtractionController.totalQuestions}',
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
