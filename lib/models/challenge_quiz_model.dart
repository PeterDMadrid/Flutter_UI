import 'package:flutter_hands/screens/challenge/widgets/mode_button.dart';

class ChallengeQuizModel {
  final int firstNumber;
  final int secondNumber;
  final int correctAnswer;
  final bool isAnswered;
  final bool isCorrect; // Changed to non-nullable
  final MathMode mode;

  ChallengeQuizModel({
    required this.firstNumber,
    required this.secondNumber,
    required this.correctAnswer,
    required this.mode,
    this.isAnswered = false,
    this.isCorrect = false, // Default to false
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

  // Method to check the answer
  bool checkAnswer(int answer) {
    return answer == correctAnswer; // Check if the answer is correct
  }
}