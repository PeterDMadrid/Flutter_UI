class SigningModel {
  final int correctNumber;
  final bool isAnswered;
  final bool? isCorrect;

  SigningModel({
    required this.correctNumber,
    this.isAnswered = false,
    this.isCorrect
  });

  SigningModel copyWith({
    int? correctNumber,
    bool? isAnswered,
    bool? isCorrect
  }) {
    return SigningModel(
      correctNumber: correctNumber ?? this.correctNumber,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect:  isCorrect ?? this.isCorrect
    );
  }
}
