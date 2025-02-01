import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/signing_controller.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_hands/screens/practice/widgets/hand_detection_smoother.dart';
import 'package:flutter_hands/screens/practice/widgets/rectangular_progress_border_painter.dart';

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

  //FOR CIRCULAR PROGRESS
  double _progress = 0.0;
  Timer? _progressTimer;
  bool _isProgressVisible = false;
  final int totalDurationInSeconds = 3;

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
      await controller.startImageStream((CameraImage image) {
        if (DateTime.now().millisecondsSinceEpoch % 2 == 0) {
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

  final handDetectionSmoother = HandDetectionSmoother(windowSize: 5);

  Future<void> _detectHands(CameraImage cameraImage) async {
    if (_isDetecting) return;
    _isDetecting = true;

    try {
      // Create InputImage from CameraImage
      final inputImage = _createInputImage(cameraImage);

      // Initialize PoseDetector
      final poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          model: PoseDetectionModel.base,
          mode: PoseDetectionMode.stream,
        ),
      );

      // Process the image and detect poses
      final List<Pose> poses = await poseDetector.processImage(inputImage);

      // Check for hands in the detected poses
      final bool handDetected = _checkForHands(poses);

      // Update the state with smoothed detection result
      if (mounted) {
        setState(() {
          _hasHand = handDetectionSmoother.smoothDetection(handDetected);
        });
        print('Hand Detection Result: $_hasHand');

        // Handle progress based on hand detection
        if (_hasHand && !_isProcessing) {
          _startProgress(); // Start or continue progress
        } else {
          _cancelProgress(); // Cancel progress if no hand is detected
        }
      }

      // Close the pose detector
      await poseDetector.close();
    } catch (e) {
      print('Hand Detection Error: $e');
      if (mounted) {
        setState(() {
          _hasHand = false;
          _cancelProgress(); // Cancel progress on error
        });
      }
    } finally {
      _isDetecting = false;
    }
  }

  void _startProgress() {
    if (_progressTimer != null && _progressTimer!.isActive) return;

    setState(() {
      _progress = 0.0;
      _isProgressVisible = true;
    });

    const int timerIntervalInMilliseconds = 30;
    final int totalSteps =
        (totalDurationInSeconds * 1000) ~/ timerIntervalInMilliseconds;
    final double increment = 1.0 / totalSteps;

    _progressTimer = Timer.periodic(
        Duration(milliseconds: timerIntervalInMilliseconds), (timer) {
      if (mounted) {
        setState(() {
          _progress += increment;
          if (_progress >= 1.0) {
            _progressTimer?.cancel();
            _isProgressVisible = false;
            _captureAndPredict();
            print("finished");
          }
        });
      }
    });
  }

  void _cancelProgress() {
    // Cancel the timer and reset progress
    _progressTimer?.cancel();
    setState(() {
      _progress = 0.0;
      _isProgressVisible = false;
    });
  }

// Create InputImage from CameraImage
  InputImage _createInputImage(CameraImage cameraImage) {
    return InputImage.fromBytes(
      bytes: cameraImage.planes[0].bytes,
      metadata: InputImageMetadata(
        size: Size(cameraImage.width.toDouble(), cameraImage.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: cameraImage.planes[0].bytesPerRow,
      ),
    );
  }

// Check for hands in the detected poses
  bool _checkForHands(List<Pose> poses) {
    const handLandmarks = [
      PoseLandmarkType.leftWrist,
      PoseLandmarkType.rightWrist,
      PoseLandmarkType.leftPinky,
      PoseLandmarkType.rightPinky,
      PoseLandmarkType.leftIndex,
      PoseLandmarkType.rightIndex,
      PoseLandmarkType.leftThumb,
      PoseLandmarkType.rightThumb,
    ];

    return poses.any((pose) {
      final landmarks = pose.landmarks;

      // Count confident hand landmarks
      final confidentHandLandmarks = handLandmarks.where((type) {
        final landmark = landmarks[type];
        return landmark != null && landmark.likelihood > 0.1;
      }).toList();

      // Require at least 2 confident landmarks to detect a hand
      return confidentHandLandmarks.length >= 2;
    });
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
    String apiUrl = 'http://${GlobalVariables.server}/api/auth/save_score/'; // Replace with your actual endpoint
    final userData = await AuthService.getUserData(); 
    final token =  await getToken();
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'username': userData?['username'], // Replace with the actual username or user ID
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
        title: const Text('Quiz Complete!'),
        content: Text(
            'Your score: ${_signingController.score}/${SigningController.totalQuestions}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
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
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Camera preview
                    _buildCameraPreview(),

                    // CustomPaint to draw the rectangular progress border
                    if (_isProgressVisible)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 64.0),
                        child: AspectRatio(
                          aspectRatio: 2 / 3,
                          child: CustomPaint(
                            size: Size.infinite,
                            painter: RectangularProgressBorderPainter(
                              progress: _progress,
                              strokeWidth: 6.0,
                              color: const Color.fromARGB(255, 55, 151, 59),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (_label.isNotEmpty) _buildPredictionResult(),
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

  Widget _buildPredictionResult() {
    return Padding(
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
    );
  }
}
