import 'package:flutter/material.dart';
import 'package:flutter_hands/base/widgets/okay_button.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class Instructions extends StatelessWidget {
  const Instructions({
    super.key,
    required this.onGotIt,
    required this.instructionContent
  });

  final VoidCallback onGotIt;
  final String instructionContent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppStyles.textColor,
      child: Container(
        decoration: BoxDecoration(color: AppStyles.backgroundColor),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppStyles.myblue,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions',
                  style: AppStyles.headLineStyle2
                ),
                const SizedBox(height: 16),
                Text(
                  instructionContent,
                  style: AppStyles.paragraph2
                ),
                const SizedBox(height: 24),
                OkayButton(onProceed: onGotIt)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
