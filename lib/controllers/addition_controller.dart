import 'dart:math';
import 'package:flutter_hands/models/addition_model.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';

class AdditionController {
  int totalQuestions = 5;
  final Difficulty difficulty;

  int currentQuestionIndex = 0;
  int score = 0;

  final random = Random();
  List<AdditionModel> questions = [];

  AdditionController({required this.difficulty}) {
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

  //sum between 0-9
  void _generateEasyQuestions() {
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber;
      int secondNumber;

      do {
        firstNumber = random.nextInt(9);
        int maxSecond = 9 - firstNumber;
        secondNumber = random.nextInt(maxSecond + 1);
      } while (firstNumber == 0 && secondNumber == 0);

      questions.add(AdditionModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber + secondNumber,
      ));
    }
  }

//sum between 11-30
  void _generateMediumQuestions() {
    int firstNumber = 0;
    int secondNumber = 0;
    for (int i = 0; i < totalQuestions; i++) {
      int sum;

      do {
        firstNumber = random.nextInt(30);

        int minSecond = max(11 - firstNumber, 0);
        int maxSecond = 30 - firstNumber;

        if (minSecond <= maxSecond) {
          secondNumber = minSecond + random.nextInt(maxSecond - minSecond + 1);
          sum = firstNumber + secondNumber;
        } else {
          sum = 0;
        }
      } while (sum < 11 || sum > 30);

      questions.add(AdditionModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: sum,
      ));
    }
  }

  // Sum to be 31-99
  void _generateHardQuestions() {
    int firstNumber = 0;
    int secondNumber = 0;
    for (int i = 0; i < totalQuestions; i++) {
      int sum;

      do {
        firstNumber = random.nextInt(98) + 1;
        int minSecond = max(31 - firstNumber, 0);
        int maxSecond = 99 - firstNumber;

        if (minSecond <= maxSecond) {
          secondNumber = minSecond + random.nextInt(maxSecond - minSecond + 1);
          sum = firstNumber + secondNumber;
        } else {
          // force the loop
          sum = 0;
        }
      } while (sum < 31 || sum > 99);

      questions.add(AdditionModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: sum,
      ));
    }
  }

  // For example, the user answered 27, it till be [2, 7]. because ill be answering one by one not imidiately 27
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
