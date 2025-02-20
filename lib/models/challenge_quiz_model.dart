import 'package:flutter_hands/screens/challenge/widgets/mode_button.dart';

class ChallengeQuizModel {
  final int firstNumber;
  final int secondNumber;
  final int correctAnswer;
  final bool isAnswered;
  final bool? isCorrect;
  final MathMode mode;

  ChallengeQuizModel({
    required this.firstNumber,
    required this.secondNumber,
    required this.correctAnswer,
    required this.mode,
    this.isAnswered = false,
    this.isCorrect,
  });

  ChallengeQuizModel copyWith({
    int? firstNumber,
    int? secondNumber,
    int? correctAnswer,
    bool? isAnswered,
    bool? isCorrect,
    MathMode? mode,
  }) {
    return ChallengeQuizModel(
      firstNumber: firstNumber ?? this.firstNumber,
      secondNumber: secondNumber ?? this.secondNumber,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      mode: mode ?? this.mode,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  String toString() {
    return '$firstNumber ${mode == MathMode.addition ? '+' : '-'} $secondNumber';
  }
}