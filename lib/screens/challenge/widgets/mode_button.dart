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
        return Icons.looks_one_rounded;
      case 2:
        return Icons.looks_two_rounded;
      case 3:
        return Icons.looks_3_rounded;
      case 4:
        return Icons.looks_4_rounded;
      case 5:
        return Icons.looks_5_rounded;
      case 6:
        return Icons.looks_6_rounded;
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppStyles.backgroundColor,
              AppStyles.backgroundColor.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppStyles.boxShadowColor.withOpacity(0.6),
              blurRadius: 15,
              spreadRadius: 1,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select ${mode == MathMode.addition ? "Addition" : "Subtraction"} Level',
                  style: AppStyles.headLineStyle2.copyWith(
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppStyles.myblue.withOpacity(0.7),
              AppStyles.myblue.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.15),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  level,
                  style: AppStyles.paragraph1.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppStyles.paragraph1.copyWith(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}