import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/recognition_controller.dart';
import 'package:flutter_hands/screens/practice/widgets/choice_card.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  late RecognitionController _controller;
  OverlayEntry? _overlayEntry;
  bool _isAnswerLocked = false;

  static const _storage = FlutterSecureStorage();

  final String instructions = """1. Look at the number word on the screen (like "Three").
2. Find the matching hand sign for the number word in the pictures.
3. Tap the hand sign that matches the number word!""";

  @override
  void initState() {
    super.initState();
    _controller = RecognitionController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showInstructions();
    });
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

  void _handleAnswer(int selectedChoice) {
    if (_isAnswerLocked) return;

    setState(() {
      _isAnswerLocked = true;
      final isCorrect = _controller.checkAnswer(selectedChoice);
      
      // Show feedback (you can implement a better feedback UI)
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

      // Wait for feedback before moving to next question
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          if (!_controller.isQuizFinished) {
            _controller.nextQuestion();
          } else {
            _showResults();
          }
          _isAnswerLocked = false;
        });
      });
    });
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  void _showResults() async {
    // Send the recognition score to the backend
    await _sendRecognitionScoreToAPI(_controller.score);

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
          'Your score: ${_controller.score}/${RecognitionController.totalQuestions}',
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

  Future<void> _sendRecognitionScoreToAPI(int score) async {
    String apiUrl = 'http://${GlobalVariables.server}/api/auth/save_recognition_score/'; // Replace with your actual endpoint
    final token = await getToken(); // Assuming you have a method to get the token
    final userData = await AuthService.getUserData(); 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
        body: json.encode({
          'username': userData?['username'], // Replace with the actual username or user ID
          'recognition_score': score,
        }),
      );

      if (response.statusCode == 200) {
        print('Recognition score saved successfully: ${response.body}');
      } else {
        throw Exception('Failed to save recognition score: ${response.statusCode}');
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
    final currentQuestion = _controller.questions[_controller.currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recognition Practice'),
        backgroundColor: AppStyles.backgroundColor,
        foregroundColor: AppStyles.textColor,
      ),
      body: Container(
        decoration: BoxDecoration(color: AppStyles.backgroundColor),
        height: screenHeight,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Question ${_controller.currentQuestionIndex + 1}/${RecognitionController.totalQuestions}',
                style: AppStyles.headLineStyle2,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: Text(
                currentQuestion.correctNumber.toString(),
                style: AppStyles.headLineStyle1.copyWith(fontSize: 80),
              ),
            ),
            GridView.count(
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
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
