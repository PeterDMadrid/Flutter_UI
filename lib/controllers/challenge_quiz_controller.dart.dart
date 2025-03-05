import 'dart:math';
import 'package:flutter_hands/models/challenge_quiz_model.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';
import 'package:flutter_hands/screens/challenge/widgets/mode_button.dart';

class ChallengeQuizController {
  int totalQuestions;
  final dynamic difficulty;
  final MathMode mode;

  int currentQuestionIndex = 0;
  int score = 0;

  final random = Random();
  List<ChallengeQuizModel> questions = [];

  ChallengeQuizController({
    required this.difficulty,
    required this.mode,
    this.totalQuestions = 10,
  }) {
    _generateQuestions();
  }

  void _generateQuestions() {
    if (mode == MathMode.addition) {
      switch (difficulty) {
        case AdditionDifficulty.additionLevel1:
          _generateAdditionLevel1();
          break;
        case AdditionDifficulty.additionLevel2:
          _generateAdditionLevel2();
          break;
        case AdditionDifficulty.additionLevel3:
          _generateAdditionLevel3();
          break;
        case AdditionDifficulty.additionLevel4:
          _generateAdditionLevel4();
          break;
        case AdditionDifficulty.additionLevel5:
          _generateAdditionLevel5();
          break;
        case AdditionDifficulty.additionLevel6:
          _generateAdditionLevel6();
          break;
      }
    } else {
      switch (difficulty) {
        case SubtractionDifficulty.subtractionLevel1:
          _generateSubtractionLevel1();
          break;
        case SubtractionDifficulty.subtractionLevel2:
          _generateSubtractionLevel2();
          break;
        case SubtractionDifficulty.subtractionLevel3:
          _generateSubtractionLevel3();
          break;
        case SubtractionDifficulty.subtractionLevel4:
          _generateSubtractionLevel4();
          break;
        case SubtractionDifficulty.subtractionLevel5:
          _generateSubtractionLevel5();
          break;
        case SubtractionDifficulty.subtractionLevel6:
          _generateSubtractionLevel6();
          break;
      }
    }
  }

  void _generateAdditionLevel1() {
    // Single Digit Pairs (0-9)
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = random.nextInt(10);
      int secondNumber = random.nextInt(10);

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber + secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateAdditionLevel2() {
    // Doubles Plus One
    for (int i = 0; i < totalQuestions; i++) {
      int baseNumber = random.nextInt(9) + 1; // 1-9
      bool addToFirst = random.nextBool();

      int firstNumber = addToFirst ? baseNumber + 1 : baseNumber;
      int secondNumber = addToFirst ? baseNumber : baseNumber + 1;

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber + secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateAdditionLevel3() {
    // Generate and shuffle numbers 1-9
    List<int> uniqueNumbers = List.generate(9, (index) => index + 1)
      ..shuffle(random);

    for (int i = 0; i < totalQuestions; i++) {
      int secondNumber =
          uniqueNumbers[i % uniqueNumbers.length]; // Cycle through list

      // Prevent consecutive duplicate numbers
      if (i > 0 && questions.last.secondNumber == secondNumber) {
        secondNumber = uniqueNumbers[(i + 1) % uniqueNumbers.length];
      }

      questions.add(ChallengeQuizModel(
        firstNumber: 10,
        secondNumber: secondNumber,
        correctAnswer: 10 + secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateAdditionLevel4() {
    // Bridging Ten (sums crossing 10)
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = random.nextInt(4) + 7; // 7-10
      int secondNumber = random.nextInt(5) + 3; // 3-7

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber + secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateAdditionLevel5() {
    // Double Digits within 20
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = random.nextInt(9) + 11; // 11-19
      int secondNumber = random.nextInt(5) + 1; // 1-5

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber + secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateAdditionLevel6() {
    // Larger Two-Digit Numbers
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = random.nextInt(30) + 21; // 21-50
      int secondNumber = random.nextInt(30) + 11; // 11-40

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber + secondNumber,
        mode: mode,
      ));
    }
  }

  // Subtraction level generators
  void _generateSubtractionLevel1() {
    // Facts Within Ten
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = random.nextInt(6) + 4; // 4-9
      int secondNumber =
          random.nextInt(firstNumber - 1) + 1; // 1 to firstNumber-1

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber - secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateSubtractionLevel2() {
    // Generate and shuffle numbers 1-9
    List<int> uniqueNumbers = List.generate(9, (index) => index + 1)
      ..shuffle(random);

    for (int i = 0; i < totalQuestions; i++) {
      int secondNumber =
          uniqueNumbers[i % uniqueNumbers.length]; // Cycle through list

      // Prevent consecutive duplicate numbers
      if (i > 0 && questions.last.secondNumber == secondNumber) {
        secondNumber = uniqueNumbers[(i + 1) % uniqueNumbers.length];
      }

      questions.add(ChallengeQuizModel(
        firstNumber: 10,
        secondNumber: secondNumber,
        correctAnswer: 10 - secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateSubtractionLevel3() {
    // Near Ten Subtraction
    for (int i = 0; i < totalQuestions; i++) {
      bool useEleven = random.nextBool();
      int firstNumber = useEleven ? 11 : 9;
      int secondNumber = random.nextInt(4) + 1; // 1-4

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber - secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateSubtractionLevel4() {
    // Teen Take-Aways
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = random.nextInt(5) + 13; // 13-17
      int secondNumber = random.nextInt(7) + 3; // 3-9

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber - secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateSubtractionLevel5() {
    // Bridging Ten
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = random.nextInt(5) + 12; // 12-16
      int secondNumber = random.nextInt(4) + 4; // 4-7

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber - secondNumber,
        mode: mode,
      ));
    }
  }

  void _generateSubtractionLevel6() {
    // Larger Two-Digit Numbers
    for (int i = 0; i < totalQuestions; i++) {
      int firstNumber = random.nextInt(40) + 35; // 35-74
      int secondNumber = random.nextInt(25) + 15; // 15-39

      questions.add(ChallengeQuizModel(
        firstNumber: firstNumber,
        secondNumber: secondNumber,
        correctAnswer: firstNumber - secondNumber,
        mode: mode,
      ));
    }
  }

  bool checkAnswer(List handSigns) {
    final currentQuestion = questions[currentQuestionIndex];
    int answer = int.parse(handSigns.join());
    final isCorrect = currentQuestion.checkAnswer(answer);

    if (isCorrect) {
      score++;
    } else {
      print(
          'Incorrect! The correct answer is ${currentQuestion.correctAnswer}.');
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
