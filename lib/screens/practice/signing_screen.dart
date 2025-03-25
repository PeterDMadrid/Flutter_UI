import 'dart:io';
import 'dart:async';
import 'dart:convert';
import '../../main.dart';
import 'package:gif/gif.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/widgets/phrases.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/widgets/instructions.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/widgets/camera_controls.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/controllers/signing_controller.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/base/widgets/next_question_button.dart';
import 'package:flutter_hands/services/image_prediction_service.dart';
import 'package:flutter_hands/base/widgets/handsigns_camera_preview.dart';
import 'package:flutter_hands/screens/practice/widgets/question_text_widget.dart';

class SigningScreen extends StatefulWidget {
  const SigningScreen({super.key});

  @override
  State<SigningScreen> createState() => _SigningScreenState();
}

class _SigningScreenState extends State<SigningScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  CameraController? _cameraController;
  bool _isFrontCamera = false;
  String _errorMessage = '';
  bool _isInitialized = false;
  late SigningController _signingController;
  bool _showNextButton = false;

  bool _isProcessing = false;
  int _prediction = -1;
  String _label = '';
  String _handedness = '';
  double _confidence = 0.0;

  int _signingScore = 0;
  static const _storage = FlutterSecureStorage();

  //teacher gif
  bool showGif = false;
  late final GifController _teacherController;
  bool _lastAnswerCorrect = false;

//Audio
  final AudioPlayer _audioPlayer = AudioPlayer();

  final String instructions =
      "Show your signing skills! Read the number and sign it correctly";

  final String bottomInstructions =
      "Use the camera to capture your sign. Make sure your hand is visible before clicking capture!";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
    _initializeAudioPlayer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
    _signingController = SigningController();
    _teacherController = GifController(vsync: this);
  }

  File? _capturedImageFile;
  bool _showCapturedImage = false;

  Future<void> _captureAndPredict(bool isDarkMode) async {
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

      setState(() {
        _capturedImageFile = File(image.path);
        _showCapturedImage = true;
      });

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

      // Only handle valid predictions
      if (_prediction >= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleAnswer(_prediction, isDarkMode);
        });
      } else {
        setState(() {
          _showCapturedImage = false;
          _capturedImageFile = null;
        });
        // Show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hand detected. Please try again.')),
        );
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _showCapturedImage = false;
        _capturedImageFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _overlayEntry?.remove();
    _cameraController?.dispose();
    _audioPlayer.dispose();
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
          bottomInstruction: bottomInstructions,
          images: const [
            'assets/instructions/signing_instruction_1.JPG',
            'assets/instructions/signing_instruction_2.JPG',
            'assets/instructions/signing_instruction_3.JPG',
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

  Future<void> _handleAnswer(int handSign, bool isDarkMode) async {
    final isCorrect = _signingController.checkAnswer(handSign);
    _lastAnswerCorrect = isCorrect;

    if (isCorrect) {
      _signingScore++;
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
  }

  void _handleNext(isDarkMode) {
    setState(() {
      _showCapturedImage = false;
      _capturedImageFile = null;

      if (!_signingController.isQuizFinished) {
        _signingController.nextQuestion();
        _showNextButton = false;
        showGif = false;
      } else {
        _showResults();
        showGif = false;
      }
    });
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<void> _sendScoreToAPI(int score) async {
    String apiUrl = 'http://${GlobalVariables.server}/api/auth/save_score/';
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
          'username': userData?['username'],
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
    _sendScoreToAPI(_signingScore);

    final isDarkMode = ThemeManager().isDarkModeNotifier.value;

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
          'Your score: $_signingScore/${SigningController.totalQuestions}',
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

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double teacherSize = MediaQuery.of(context).size.width * 0.7;
    final currentQuestion =
        _signingController.questions[_signingController.currentQuestionIndex];
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Signing Practice'),
              backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
              foregroundColor: AppStyles.getTextColor(isDarkMode),
            ),
            body: _buildBody(
                screenHeight, currentQuestion, isDarkMode, teacherSize),
          );
        });
  }

  Widget _buildBody(double screenHeight, final currentQuestion, bool isDarkMode,
      double teacherSize) {
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
                SizedBox(height: screenHeight * 0.030),
                Column(
                  children: [
                    Text(
                        'Question ${_signingController.currentQuestionIndex + 1}/${SigningController.totalQuestions}',
                        style: AppStyles.getHeadLineStyle2(isDarkMode)),
                  ],
                ),
                SizedBox(height: screenHeight * 0.020),
                QuestionTextWidget(
                  isDarkMode: isDarkMode,
                  showNextButton: _showNextButton,
                  correctNumber: currentQuestion.correctNumber,
                  prediction: _prediction,
                ),
                SizedBox(height: screenHeight * 0.020),
                HandSignCameraPreview(
                  isFrontCamera: _isFrontCamera,
                  cameraController: _cameraController,
                  capturedImageFile: _capturedImageFile,
                  showCapturedImage: _showCapturedImage,
                ),
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
                                    _signingController.currentQuestionIndex %
                                        positivePhrases.length]
                                : negativePhrases[
                                    _signingController.currentQuestionIndex %
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
