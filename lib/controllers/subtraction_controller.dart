import 'dart:math';
import 'package:flutter_hands/models/subtraction_model.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';

class SubtractionController {
  int totalQuestions = 5;
  final Difficulty difficulty;

  int currentQuestionIndex = 0;
  int score = 0;

  final random = Random();
  List<SubtractionModel> questions = [];

  SubtractionController({required this.difficulty}) {
    _generateQuestions();
  }

  void _generateQuestions() {
    switch (difficulty) {
      case Difficulty.easy:
        _generateEasyQuestions();
        break;
      case Difficulty.medium:
        _generateMediumQuestions();
        break;
      case Difficulty.hard:
        _generateHardQuestions();
        break;
    }
  }

  // Difference between 0-9
  void _generateEasyQuestions() {
    for (int i = 0; i < totalQuestions; i++) {
      // First number between 1-9
      final firstNumber = random.nextInt(9) + 1;
      // Second number between 0 and firstNumber (to ensure positive difference)
      final secondNumber = random.nextInt(firstNumber);

      questions.add(SubtractionModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber - secondNumber,
      ));
    }
  }

  // Difference between 11-30
  void _generateMediumQuestions() {
    int firstNumber;
    int secondNumber;
    int difference;
    for (int i = 0; i < totalQuestions; i++) {
      do {
        // First number between 11-99
        firstNumber = random.nextInt(89) + 11;

        // Calculate bounds for second number
        final maxSecond = min(99,
            firstNumber - 11); // Ensure difference >= 11 and secondNumber <= 99
        final minSecond = max(0, firstNumber - 30); // Ensure difference <= 30

        secondNumber = minSecond + random.nextInt(maxSecond - minSecond + 1);
        difference = firstNumber - secondNumber;
      } while (difference < 11 || difference > 30);

      questions.add(SubtractionModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: difference,
      ));
    }
  }

  // Difference between 31-99
  void _generateHardQuestions() {
    int firstNumber;
    int secondNumber;
    int difference;
    for (int i = 0; i < totalQuestions; i++) {
      do {
        // First number between 31-99
        firstNumber = random.nextInt(69) + 31;

        // Calculate bounds for second number
        final maxSecond = min(99,
            firstNumber - 31); // Ensure difference >= 31 and secondNumber <= 99
        final minSecond = max(0, firstNumber - 99); // Ensure difference <= 99

        secondNumber = minSecond + random.nextInt(maxSecond - minSecond + 1);
        difference = firstNumber - secondNumber;
      } while (difference < 31 || difference > 99);

      questions.add(SubtractionModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: difference,
      ));
    }
  }

  bool checkAnswer(List handSigns) {
    final currentQuestion = questions[currentQuestionIndex];
    int answer = int.parse(handSigns.join());
    final isCorrect = answer == currentQuestion.correctAnswer;

    if (isCorrect) {
      score++;
    }

    questions[currentQuestionIndex] = currentQuestion.copyWith(
      isCorrect: isCorrect,
    );

    return isCorrect;
  }

  bool get isQuizFinished => currentQuestionIndex >= totalQuestions - 1;

  void nextQuestion() {
    if (!isQuizFinished) {
      currentQuestionIndex++;
    }
  }
}
