import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class AnswerDisplay extends StatelessWidget {
  final List<int> currentAnswer;
  final int expectedLength;
  final TextStyle? style;

  const AnswerDisplay({
    super.key,
    required this.currentAnswer,
    required this.expectedLength,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (expectedLength == 1) {
      return Text(
        currentAnswer.isEmpty ? '_' : currentAnswer[0].toString(),
        style: style ?? AppStyles.headLineStyle2.copyWith(fontSize: 38),
      );
    }

    // For double-digit answers
    String displayText = '';

    if (currentAnswer.isEmpty) {
      displayText = '__';
    } else if (currentAnswer.length == 1) {
      displayText = '${currentAnswer[0]}_';
    } else {
      displayText = '${currentAnswer[0]}${currentAnswer[1]}';
    }

    return Text(
      displayText,
      style: style ?? AppStyles.headLineStyle2.copyWith(fontSize: 42),
    );
  }
}
