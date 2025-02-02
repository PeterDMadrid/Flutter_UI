import 'dart:async';
import 'dart:io';
import 'dart:convert';
import '../../main.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/signing_controller.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';
import 'package:flutter_hands/screens/practice/widgets/hand_detection_smoother.dart';
import 'package:flutter_hands/screens/practice/widgets/rectangular_progress_border_painter.dart';

class AdditionSigningScreen extends StatefulWidget {
  const AdditionSigningScreen({super.key});

  @override
  State<AdditionSigningScreen> createState() => _AdditionSigningScreenState();
}

class _AdditionSigningScreenState extends State<AdditionSigningScreen> with WidgetsBindingObserver {
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
  double _progress = 0.0;
  Timer? _progressTimer;
  bool _isProgressVisible = false;
  final int totalDurationInSeconds = 3;

  int _score = 0;
  int _correctAnswer = 0;
  String _currentQuestion = '';
  int _userAnswer = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _signingController = SigningController();
    _generateNewQuestion();
  }

  // Generate new addition question
  void _generateNewQuestion() {
    final int num1 = _getRandomNumber();
    final int num2 = _getRandomNumber();
    _correctAnswer = num1 + num2;
    _currentQuestion = '$num1 + $num2 = ?';
  }

  int _getRandomNumber() {
    return (1 + (10 * (new DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).floor();
  }

  Future<void> _captureAndPredict() async {
    if (_isProcessing || _cameraController == null || !_cameraController!.value.isInitialized) {
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
    String apiUrl = 'http://${GlobalVariables.server}/api/predict/';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
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
      final inputImage = _createInputImage(cameraImage);
      final poseDetector = PoseDetector(
        options: PoseDetectorOptions(
          model: PoseDetectionModel.base,
          mode: PoseDetectionMode.stream,
        ),
      );

      final List<Pose> poses = await poseDetector.processImage(inputImage);
      final bool handDetected = _checkForHands(poses);

      if (mounted) {
        setState(() {
          _hasHand = handDetectionSmoother.smoothDetection(handDetected);
        });

        if (_hasHand && !_isProcessing) {
          _startProgress();
        } else {
          _cancelProgress();
        }
      }

      await poseDetector.close();
    } catch (e) {
      print('Hand Detection Error: $e');
      if (mounted) {
        setState(() {
          _hasHand = false;
          _cancelProgress();
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
    final int totalSteps = (totalDurationInSeconds * 1000) ~/ timerIntervalInMilliseconds;
    final double increment = 1.0 / totalSteps;

    _progressTimer = Timer.periodic(Duration(milliseconds: timerIntervalInMilliseconds), (timer) {
      if (mounted) {
        setState(() {
          _progress += increment;
          if (_progress >= 1.0) {
            _progressTimer?.cancel();
            _isProgressVisible = false;
            _captureAndPredict();
          }
        });
      }
    });
  }

  void _cancelProgress() {
    _progressTimer?.cancel();
    setState(() {
      _progress = 0.0;
      _isProgressVisible = false;
    });
  }
  void _toggleCamera() async {
    if (globalCameras.length < 2) return;

    setState(() {
      _isFrontCamera = !_isFrontCamera;
      _isInitialized = false;
    });

    await _initializeCamera();
  }

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
      final confidentHandLandmarks = handLandmarks.where((type) {
        final landmark = landmarks[type];
        return landmark != null && landmark.likelihood > 0.1;
      }).toList();
      return confidentHandLandmarks.length >= 2;
    });
  }

  void _handleAnswer(int handSign) {
    setState(() {
      final isCorrect = handSign == _correctAnswer;
      if (isCorrect) {
        _score++;
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
          _generateNewQuestion();
          _isProcessing = false;
        });
      });
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
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signing Addition Practice'),
        backgroundColor: AppStyles.backgroundColor,
        foregroundColor: AppStyles.textColor,
      ),
      body: _buildBody(screenHeight),
    );
  }

  Widget _buildBody(double screenHeight) {
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
                        'Score: $_score',
                        style: AppStyles.headLineStyle2,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Question: $_currentQuestion',
                        style: AppStyles.headLineStyle1,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.025),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildCameraPreview(),
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
