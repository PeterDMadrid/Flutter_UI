import 'dart:math';
import 'package:flutter_hands/models/challenge_quiz_model.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';
import 'package:flutter_hands/screens/challenge/widgets/mode_button.dart';

class ChallengeQuizController {
  int totalQuestions = 5;
  final Difficulty difficulty;
  final MathMode mode;

  int currentQuestionIndex = 0;
  int score = 0;

  final random = Random();
  List<ChallengeQuizModel> questions = [];

  ChallengeQuizController({required this.difficulty, required this.mode}) {
    _generateQuestions();
  }

  void _generateQuestions() {
    switch (difficulty) {
      case Difficulty.easy:
        mode == MathMode.addition
            ? _generateEasyAdditionQuestions()
            : _generateEasySubtractionQuestions();
        break;
      case Difficulty.medium:
        mode == MathMode.addition
            ? _generateMediumAdditionQuestions()
            : _generateMediumSubtractionQuestions();
        break;
      case Difficulty.hard:
        mode == MathMode.addition
            ? _generateHardAdditionQuestions()
            : _generateHardSubtractionQuestions();
        break;
    }
  }

  void _generateEasyAdditionQuestions() {
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber;
      int secondNumber;

      do {
        firstNumber = random.nextInt(9);
        int maxSecond = 9 - firstNumber;
        secondNumber = random.nextInt(maxSecond + 1);
      } while (firstNumber == 0 && secondNumber == 0);

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber + secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateEasySubtractionQuestions() {
    for (int i = 0; i < totalQuestions; i++) {
      final firstNumber = random.nextInt(9) + 1;
      final secondNumber = random.nextInt(firstNumber);

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber - secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateMediumAdditionQuestions() {
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = 0;
      int secondNumber = 0;
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

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: sum,
        mode: mode,
      ));
    }
  }

  void _generateMediumSubtractionQuestions() {
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber;
      int secondNumber;
      int difference;

      do {
        firstNumber = random.nextInt(89) + 11;
        final maxSecond = min(99, firstNumber - 11);
        final minSecond = max(0, firstNumber - 30);

        secondNumber = minSecond + random.nextInt(maxSecond - minSecond + 1);
        difference = firstNumber - secondNumber;
      } while (difference < 11 || difference > 30);

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: difference,
        mode: mode,
      ));
    }
  }

  void _generateHardAdditionQuestions() {
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = 0;
      int secondNumber = 0;
      int sum;

      do {
        firstNumber = random.nextInt(98) + 1;
        int minSecond = max(31 - firstNumber, 0);
        int maxSecond = 99 - firstNumber;

        if (minSecond <= maxSecond) {
          secondNumber = minSecond + random.nextInt(maxSecond - minSecond + 1);
          sum = firstNumber + secondNumber;
        } else {
          sum = 0;
        }
      } while (sum < 31 || sum > 99);

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: sum,
        mode: mode,
      ));
    }
  }

  void _generateHardSubtractionQuestions() {
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber;
      int secondNumber;
      int difference;

      do {
        firstNumber = random.nextInt(69) + 31;
        final maxSecond = min(99, firstNumber - 31);
        final minSecond = max(0, firstNumber - 99);

        secondNumber = minSecond + random.nextInt(maxSecond - minSecond + 1);
        difference = firstNumber - secondNumber;
      } while (difference < 31 || difference > 99);

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: difference,
        mode: mode,
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