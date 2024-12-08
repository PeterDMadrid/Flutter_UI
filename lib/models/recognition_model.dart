class RecognitionModel {
  final int correctNumber;
  final List<int> choices;
  final bool isAnswered;
  final bool? isCorrect;

  RecognitionModel({
    required this.correctNumber,
    required this.choices,
    this.isAnswered = false,
    this.isCorrect,
  });

  RecognitionModel copyWith({
    int? correctNumber,
    List<int>? choices,
    bool? isAnswered,
    bool? isCorrect,
  }) {
    return RecognitionModel(
      correctNumber: correctNumber ?? this.correctNumber,
      choices: choices ?? this.choices,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}
