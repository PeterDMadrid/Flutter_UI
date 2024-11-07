import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class StartButton extends StatelessWidget {
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            minimumSize: Size(constraints.maxWidth, 80),
          ),
          child: Text(
            "START",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 32,
              color: AppStyles.textColor,
            ),
          ),
        );
      },
    );
  }
}