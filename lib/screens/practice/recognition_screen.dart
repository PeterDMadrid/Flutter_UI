import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/controllers/recognition_controller.dart';
import 'package:flutter_hands/screens/practice/widgets/choice_card.dart';
import 'package:flutter_hands/screens/practice/widgets/instructions.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  late RecognitionController _controller;
  OverlayEntry? _overlayEntry;
  bool _isAnswerLocked = false;

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
          backgroundColor: isCorrect?Colors.teal : Colors.red  ,
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

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Text('Your score: ${_controller.score}/${RecognitionController.totalQuestions}'),
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
