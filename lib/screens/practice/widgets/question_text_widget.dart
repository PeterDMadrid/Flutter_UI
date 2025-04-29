import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class QuestionTextWidget extends StatelessWidget {
  final bool isDarkMode;
  final bool showNextButton;
  final int correctNumber;
  final int? prediction;

  const QuestionTextWidget({
    super.key,
    required this.isDarkMode,
    required this.showNextButton,
    required this.correctNumber,
    this.prediction,
  });

  @override
  Widget build(BuildContext context) {
    List<String> numberWords = [
      "zero",
      "one",
      "two",
      "three",
      "four",
      "five",
      "six",
      "seven",
      "eight",
      "nine"
    ];

    return RichText(
      text: TextSpan(
        style: AppStyles.getHeadLineStyle1(isDarkMode),
        children: showNextButton
            ? [
                // const TextSpan(
                //   text: "You signed ",
                //   style: TextStyle(fontSize: 20),
                // ),
                // TextSpan(
                //   text: "${numberWords[prediction!]} ($prediction)",
                //   style: TextStyle(
                //     fontSize: 25,
                //     color: AppStyles.buttonColor,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
                if (prediction != correctNumber) ...[
                  const TextSpan(
                    text:
                        "Incorrect!",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  // TextSpan(
                  //   text:
                  //       " ${numberWords[correctNumber]} ($correctNumber)",
                  //   style: TextStyle(
                  //     fontSize: 25,
                  //     color: AppStyles.buttonColor,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                ] else ...[
                  const TextSpan(
                    text: "Correct!",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ]
              ]
            : [
                const TextSpan(
                  text: "How do you sign the number ",
                  style: TextStyle(fontSize: 20),
                ),
                TextSpan(
                  text: "${numberWords[correctNumber]} ($correctNumber)",
                  style: TextStyle(
                    fontSize: 25,
                    color: AppStyles.buttonColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
      ),
    );
  }
}
