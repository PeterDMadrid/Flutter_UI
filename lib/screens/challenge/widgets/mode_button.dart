import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';

enum MathMode { addition, subtraction }

class MathModeDialog extends StatelessWidget {
  final MathMode mode;
  const MathModeDialog({super.key, required this.mode});

  String _getDifficultyTitle(dynamic difficulty) {
    switch (difficulty) {
      case AdditionDifficulty.additionLevel1:
        return "Single Digit Pairs";
      case AdditionDifficulty.additionLevel2:
        return "Doubles Plus One";
      case AdditionDifficulty.additionLevel3:
        return "Teen Numbers";
      case AdditionDifficulty.additionLevel4:
        return "Bridging Ten";
      case AdditionDifficulty.additionLevel5:
        return "Double Digits";
      case AdditionDifficulty.additionLevel6:
        return "Adding Larger Two-Digit Numbers";
      case SubtractionDifficulty.subtractionLevel1:
        return "Facts Within Ten";
      case SubtractionDifficulty.subtractionLevel2:
        return "Taking From Ten";
      case SubtractionDifficulty.subtractionLevel3:
        return "Near Ten Subtraction";
      case SubtractionDifficulty.subtractionLevel4:
        return "Teen Take-Aways";
      case SubtractionDifficulty.subtractionLevel5:
        return "Bridging Ten";
      case SubtractionDifficulty.subtractionLevel6:
        return "Subtracting Larger Two-Digit Numbers";
      default:
        return "Unknown Level";
    }
  }

  IconData _getDifficultyIcon(int level) {
    switch (level) {
      case 1:
      case 2:
        return Icons.sentiment_very_satisfied_outlined;
      case 3:
      case 4:
        return Icons.sentiment_satisfied_outlined;
      case 5:
      case 6:
        return Icons.sentiment_very_dissatisfied_outlined;
      default:
        return Icons.question_mark;
    }
  }

  List<dynamic> _getDifficultyLevels() {
    return mode == MathMode.addition
        ? AdditionDifficulty.values
        : SubtractionDifficulty.values;
  }

  @override
  Widget build(BuildContext context) {
    final levels = _getDifficultyLevels();

    return Dialog(
      backgroundColor: AppStyles.roseRed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select ${mode == MathMode.addition ? "Addition" : "Subtraction"} Level',
                style: AppStyles.headLineStyle2,
              ),
              const SizedBox(height: 24),
              ...List.generate(
                levels.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index < levels.length - 1 ? 16.0 : 0,
                  ),
                  child: _ModeButton(
                    title: _getDifficultyTitle(levels[index]),
                    icon: _getDifficultyIcon(index + 1),
                    level: "Level ${index + 1}",
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                        context,
                        '/challenge_quiz',
                        arguments: {
                          'mode': mode,
                          'difficulty': levels[index],
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
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
    required this.level,
  });

  final String title;
  final String level;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 24,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    level,
                    style: AppStyles.paragraph1.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: AppStyles.paragraph1.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}