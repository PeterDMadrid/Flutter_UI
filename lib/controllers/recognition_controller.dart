import 'dart:math';
import 'package:flutter_hands/models/recognition_model.dart';

class RecognitionController {
  static const int totalQuestions = 10;
  
  int currentQuestionIndex = 0;
  int score = 0;
  List<RecognitionModel> questions = [];

  RecognitionController() {
    _generateQuestions();
  }

  void _generateQuestions() {
    for (int i = 0; i < totalQuestions; i++) {
      questions.add(_generateQuestion());
    }
  }

  RecognitionModel _generateQuestion() {
    final random = Random();
    final correctNumber = random.nextInt(10);
    
    final incorrectNumbers = <int>{};
    while (incorrectNumbers.length < 3) {
      int randomChoice = random.nextInt(10);
      if (randomChoice != correctNumber) {
        incorrectNumbers.add(randomChoice);
      }
    }

    final choices = [correctNumber, ...incorrectNumbers].toList()..shuffle();
    
    return RecognitionModel(
      correctNumber: correctNumber,
      choices: choices,
    );
  }

  bool checkAnswer(int selectedChoice) {
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = selectedChoice == currentQuestion.correctNumber;
    
    if (isCorrect) {
      score++;
    }

    questions[currentQuestionIndex] = currentQuestion.copyWith(
      isAnswered: true,
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
