import 'dart:io';
import 'dart:convert';
import '../../main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/signing_controller.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

// Import the global cameras variable

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

  bool _hasHand = false;
  bool _isDetecting = false;

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

    // Dispose of previous controller if it exists
    await _cameraController?.dispose();

    // Create new controller
    final controller = CameraController(
      globalCameras[_isFrontCamera && globalCameras.length > 1 ? 0 : 1],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    try {
      await controller.initialize();
      await controller.startImageStream((CameraImage image) {
        if (DateTime.now().millisecondsSinceEpoch % 5 == 0) {
          _detectHands(image);
        }
      });

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

  Future<void> _detectHands(CameraImage cameraImage) async {
  if (_isDetecting) return;
  _isDetecting = true;

  try {
    final inputImage = InputImage.fromBytes(
      bytes: cameraImage.planes[0].bytes!,
      metadata: InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      ),
    );

    final poseDetector = PoseDetector(
      options: PoseDetectorOptions(
        model: PoseDetectionModel.base,
        mode: PoseDetectionMode.stream,
      ),
    );

    final List<Pose> poses = await poseDetector.processImage(inputImage);

    bool handDetected = poses.any((pose) {
      final landmarks = pose.landmarks;
      
      final handLandmarks = [
        PoseLandmarkType.leftWrist,
        PoseLandmarkType.rightWrist,
        PoseLandmarkType.leftPinky,
        PoseLandmarkType.rightPinky,
        PoseLandmarkType.leftIndex,
        PoseLandmarkType.rightIndex,
        PoseLandmarkType.leftThumb,
        PoseLandmarkType.rightThumb,
      ];

      // Count confident hand landmarks
      final confidentHandLandmarks = handLandmarks.where((type) {
        final landmark = landmarks[type];
        return landmark != null && landmark.likelihood > 0.4;
      }).toList();

      // More robust hand detection
      return confidentHandLandmarks.length >= 2;
    });

    if (mounted) {
      setState(() {
        _hasHand = handDetected;
      });

      print('Hand Detection Result: $handDetected');
    }

    await poseDetector.close();
  } catch (e) {
    print('Hand Detection Error: $e');
    if (mounted) {
      setState(() {
        _hasHand = false;
      });
    }
  } finally {
    _isDetecting = false;
  }
}

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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCorrect ? 'Correct!' : 'Incorrect!'),
          duration: const Duration(seconds: 1),
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

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Text(
            'Your score: ${_signingController.score}/${SigningController.totalQuestions}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('Done'),
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
                      Text(
                        _hasHand ? 'Hand Detected ✋' : 'No Hands Detected',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
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
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 64.0), // Margin around the preview
                    child: AspectRatio(
                      aspectRatio: 2 / 3, // Camera's native aspect ratio
                      child: ClipRect(
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                ),
                if (_label.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Gesture: $_prediction',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Confidence: ${(_confidence * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Hand: $_handedness',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _hasHand ? 'Hand Detected ✋' : 'No Hands Detected',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
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

          // Camera Switch Button
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
}
