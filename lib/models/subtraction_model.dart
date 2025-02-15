class SubtractionModel {
  final int firstNumber;
  final int secondNumber;
  final int correctAnswer;
  final bool isAnswered;
  final bool? isCorrect;

  SubtractionModel({
    required this.firstNumber,
    required this.secondNumber,
    required this.correctAnswer,
    this.isAnswered = false,
    this.isCorrect,
  });

  SubtractionModel copyWith({
    int? firstNumber,
    int? secondNumber,
    int? correctAnswer,
    bool? isAnswered,
    bool? isCorrect,
  }) {
    return SubtractionModel(
      firstNumber: firstNumber ?? this.firstNumber,
      secondNumber: secondNumber ?? this.secondNumber,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  @override
  String toString() {
    return '$firstNumber - $secondNumber';
  }
}