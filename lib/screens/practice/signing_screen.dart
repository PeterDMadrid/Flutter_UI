import 'dart:io';
import 'dart:async';
import 'dart:convert';
import '../../main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/widgets/camera_controls.dart';
import 'package:flutter_hands/controllers/signing_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';
import 'package:flutter_hands/screens/practice/widgets/hand_detection_smoother.dart';


class SigningScreen extends StatefulWidget {
  const SigningScreen({super.key});

  @override
  State<SigningScreen> createState() => _SigningScreenState();
}

class _SigningScreenState extends State<SigningScreen>
    with WidgetsBindingObserver {
  OverlayEntry? _overlayEntry;
  CameraController? _cameraController;
  bool _isFrontCamera = false;
  String _errorMessage = '';
  bool _isInitialized = false;
  late SigningController _signingController;

  bool _isProcessing = false;
  int _prediction = -1;
  String _label = '';
  String _handedness = '';
  double _confidence = 0.0;

  int _signingScore = 0;
  static const _storage = FlutterSecureStorage();

  final String instructions =
      """1. Look at the number word on the screen (like "Three").
2. Use your hand to sign the number in front of the camera.
3. Wait for the app to check your sign and give feedback!""";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
    _signingController = SigningController();
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAnswer(_prediction);
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<Map<String, dynamic>> _sendImageToAPI(File imageFile) async {
    // Replace with your Django API endpoint
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

  Future<void> _initializeCamera() async {
    if (globalCameras.isEmpty) {
      setState(() {
        _errorMessage = 'No cameras found';
      });
      return;
    }

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

  final handDetectionSmoother = HandDetectionSmoother(windowSize: 5);

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayEntry?.remove();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
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

  void _handleAnswer(int handSign) {
    setState(() {
      final isCorrect = _signingController.checkAnswer(handSign);
      if (isCorrect) {
        _signingScore++; // Increment the signing score if the answer is correct
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
          if (!_signingController.isQuizFinished) {
            _isProcessing = false;
            _signingController.nextQuestion();
          } else {
            _showResults();
          }
        });
      });
    });
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> _sendScoreToAPI(int score) async {
    String apiUrl =
        'http://${GlobalVariables.server}/api/auth/save_score/'; // Replace with your actual endpoint
    final userData = await AuthService.getUserData();
    final token = await getToken();
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'username': userData?[
              'username'], // Replace with the actual username or user ID
          'signing_score': score,
        }),
      );

      if (response.statusCode == 200) {
        print('Score saved successfully: ${response.body}');
      } else {
        throw Exception('Failed to save score: ${response.statusCode}');
      }
    } catch (e) {
      print('Error saving score: $e');
    }
  }

  void _showResults() {
    // Send the signing score to the backend
    _sendScoreToAPI(_signingScore);

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
          'Your score: $_signingScore/${SigningController.totalQuestions}',
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    final currentQuestion =
        _signingController.questions[_signingController.currentQuestionIndex];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signing Practice'),
        backgroundColor: AppStyles.backgroundColor,
        foregroundColor: AppStyles.textColor,
      ),
      body: _buildBody(screenHeight, currentQuestion),
    );
  }

  Widget _buildBody(double screenHeight, final currentQuestion) {
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
                  child: Column(
                    children: [
                      Text(
                          'Question ${_signingController.currentQuestionIndex + 1}/${SigningController.totalQuestions}',
                          style: AppStyles.headLineStyle2),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.010),
                Center(
                    child: Text(
                  currentQuestion.correctNumber.toString(),
                  style: AppStyles.headLineStyle1.copyWith(fontSize: 80),
                )),
                SizedBox(height: screenHeight * 0.025),
                _buildCameraPreview(),
                // if (_label.isNotEmpty) _buildPredictionResult(),
              ],
            ),
          ),
          CameraControls(
            onCapture: _isProcessing ? () {} : _captureAndPredict,
            onToggleCamera: _toggleCamera,
            isProcessing: _isProcessing,
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
