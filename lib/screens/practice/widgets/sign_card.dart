import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hands/base/widgets/start_button.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/challenge/widgets/mode_button.dart';

enum CardType { recognition, signing, challenge }

enum AdditionDifficulty {
  additionLevel1,
  additionLevel2,
  additionLevel3,
  additionLevel4,
  additionLevel5,
  additionLevel6;

  String get name {
    switch (this) {
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
    }
  }
}

enum SubtractionDifficulty {
  subtractionLevel1,
  subtractionLevel2,
  subtractionLevel3,
  subtractionLevel4,
  subtractionLevel5,
  subtractionLevel6;

  String get name {
    switch (this) {
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
    }
  }
}

class SignCard extends StatelessWidget {
  const SignCard({
    super.key,
    required this.practiceType,
    required this.desc,
    this.cardType = CardType.recognition,
    this.index = 0,
  });

  final String practiceType;
  final String desc;
  final CardType cardType;
  final int index;

  @override
  Widget build(BuildContext context) {
    Color startColor;
    Color endColor;
    Color accentColor;
    String backgroundImage;
    String route;
    IconData cardIcon;

    switch (cardType) {
      case CardType.recognition:
        startColor = AppStyles.myblue;
        endColor = const Color(0xFF168AAD);
        accentColor = const Color(0xFF76C7C0);
        backgroundImage = AppMedia.recognitionPoster;
        route = "/recognition_screen";
        cardIcon = Icons.visibility;
        break;
      case CardType.signing:
        startColor = AppStyles.myblue;
        endColor = const Color(0xFF7A32A9);
        accentColor = const Color(0xFFC08CE0);
        backgroundImage = AppMedia.signingPoster;
        route = "/signing_screen";
        cardIcon = Icons.sign_language;
        break;
      case CardType.challenge:
        startColor = const Color(0xFF6D0F1F);
        endColor = const Color(0xFFB83248);
        accentColor = const Color(0xFFFF5C5C);
        backgroundImage = AppMedia.challengePoster;
        route = "/basic_flow_widget";
        cardIcon = Icons.extension;
        break;
    }

    return Animate(
      delay: AppStyles.getStaggeredDelay(index),
      effects: AppStyles.cardEntranceEffects2(),
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            minHeight: 310,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [startColor, endColor, endColor.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.7, 1.0],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppStyles.boxShadowColor,
                spreadRadius: 3,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      cardIcon,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      practiceType,
                      style: AppStyles.paragraph1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Flexible(
                      flex: 6,
                      child: Text(
                        desc,
                        style: AppStyles.paragraph1.copyWith(
                          fontSize: 18,
                          height: 1.3,
                        ),
                      ),
                    ),
                    const Spacer(flex: 4),
                  ],
                ),
                const SizedBox(height: 35),
                if (cardType == CardType.challenge)
                  Column(
                    children: [
                      StartButton(
                        text: "Addition",
                        color: const Color(0xFFFFD166),
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => const MathModeDialog(
                            mode: MathMode.addition,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      StartButton(
                        text: "Subtraction",
                        color: const Color(0xFF4A90E2),
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => const MathModeDialog(
                            mode: MathMode.subtraction,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  Center(
                    child: StartButton(
                      text: "START",
                      onTap: () => Navigator.pushNamed(context, route),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned(
          right: -22,
          top: -8,
          child: Image.asset(
            backgroundImage,
            width: 180,
            height: 180,
          ),
        ),
      ]),
    );
  }
}
