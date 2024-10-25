import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';


class SignCard extends StatelessWidget {
  const SignCard({super.key, required this.text, required this.isRoseRed});
  final String text;
  final bool isRoseRed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 300,
          decoration: BoxDecoration(
              color: isRoseRed?AppStyles.roseRed:AppStyles.lavender, borderRadius: BorderRadius.circular(8)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text(text, style: AppStyles.headLineStyle2,)],
            ),
          ),
        ),
      ],
    );
  }
}
