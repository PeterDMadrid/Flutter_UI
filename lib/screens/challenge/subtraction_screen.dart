import 'dart:io';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/main.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/controllers/subtraction_controller.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';

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

  late List<int> currentAnswer = [0, 0];
  bool _isProcessing = false;
  int _prediction = -1;
  String _label = ''; //remove when deploying
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

      final prediction = await _sendImageToAPI(File(image.path));

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
            currentAnswer[0] = _prediction;
            _handleAnswer([currentAnswer[0]]); // Send only the first digit
          } else {
            // For double-digit answers (medium/hard mode)
            if (currentAnswer[0] == 0) {
              currentAnswer[0] = _prediction;
            } else if (currentAnswer[1] == 0) {
              currentAnswer[1] = _prediction;
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

  Future<Map<String, dynamic>> _sendImageToAPI(File imageFile) async {
    String apiUrl = 'http://${GlobalVariables.server}/api/predict/';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to predict: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
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
          currentAnswer = [0, 0];
        } else {
          _showResults();
        }
      });
    });
  }

  Future<void> _initializeCamera() async {
    if (globalCameras.isEmpty) {
      setState(() {
        _errorMessage = 'No cameras found';
      });
      return;
    }

    // Dispose of previous controller if it exists
    await _cameraController?.dispose();

    // Create new controller
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
            style: AppStyles.headLineStyle1.copyWith(color: AppStyles.buttonColor),
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
    final currentQuestion =
        _subtractionController.questions[_subtractionController.currentQuestionIndex];
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
                // In your build method:
                Text(
                  expectedLength == 1
                      ? (currentAnswer[0] == 0
                          ? '_'
                          : currentAnswer[0].toString())
                      : (currentAnswer[0] == 0
                              ? '_'
                              : currentAnswer[0].toString()) +
                          (currentAnswer[1] == 0
                              ? '_'
                              : currentAnswer[1].toString()),
                  style: AppStyles.headLineStyle2,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _isProcessing ? null : _captureAndPredict,
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Icon(Icons.camera),
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _toggleCamera,
              child: const Icon(Icons.flip_camera_ios),
            ),
          ),
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
