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
}