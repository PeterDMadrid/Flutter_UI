import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';

enum MathMode { addition, subtraction }

class MathModeDialog extends StatelessWidget {
  final MathMode mode;
  const MathModeDialog({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppStyles.roseRed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Difficulty Level',
              style: AppStyles.headLineStyle2,
            ),
            const SizedBox(height: 24),
            _ModeButton(
              title: 'Easy',
              icon: Icons.sentiment_satisfied_outlined,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/challenge_quiz',
                  arguments: {
                    'mode': mode,
                    'difficulty': Difficulty.easy,
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _ModeButton(
              title: 'Medium',
              icon: Icons.sentiment_neutral_outlined,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/challenge_quiz',
                  arguments: {
                    'mode': mode,
                    'difficulty': Difficulty.medium,
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            _ModeButton(
              title: 'Hard',
              icon: Icons.sentiment_very_dissatisfied_outlined,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/challenge_quiz',
                  arguments: {
                    'mode': mode,
                    'difficulty': Difficulty.hard,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                weight: 700,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppStyles.paragraph1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}