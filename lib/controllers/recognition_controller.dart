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
    final allNumbers = List<int>.generate(10, (i) => i)..shuffle();

    for (int i = 0; i < totalQuestions; i++) {
      final correctNumber = allNumbers[i];

      final incorrectNumbers = allNumbers
          .where((number) => number != correctNumber)
          .take(3)
          .toList()
        ..shuffle();

      final choices = [correctNumber, ...incorrectNumbers]..shuffle();

      questions.add(RecognitionModel(
        correctNumber: correctNumber,
        choices: choices,
      ));
    }
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
