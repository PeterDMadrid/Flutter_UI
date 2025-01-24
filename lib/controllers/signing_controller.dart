import 'package:flutter_hands/models/signing_model.dart';

class SigningController {
  static const int totalQuestions = 5;

  int currentQuestionIndex = 0;
  int score = 0;
  List<SigningModel> questions = [];
  
  SigningController() {
    _generateQuestions();
  }

  void _generateQuestions() {
    final allNumbers = List<int>.generate(5, (i) => i)..shuffle();

    for (int i = 0; i < totalQuestions; i++){
    final correctNumber = allNumbers[i];

    questions.add(SigningModel(correctNumber: correctNumber));
    }
  }

  bool checkAnswer(int handSign) {
    final currentQuestion = questions[currentQuestionIndex];
    final isCorrect = handSign == currentQuestion.correctNumber;

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