import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class NextQuestionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const NextQuestionButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppStyles.buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        text,
        style: AppStyles.headLineStyle2.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }
}
