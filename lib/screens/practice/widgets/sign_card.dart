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
    String backgroundImage;
    String route;

    switch (cardType) {
      case CardType.recognition:
        startColor = AppStyles.myblue;
        endColor = AppStyles.myblue.withOpacity(0.6);
        backgroundImage = AppMedia.practiceSignBackground;
        route = "/recognition_screen";
        break;
      case CardType.signing:
        startColor = AppStyles.lavender.withOpacity(0.6);
        endColor = AppStyles.lavender;
        backgroundImage = AppMedia.practiceRecognitionBackground;
        route = "/signing_screen";
        break;
      case CardType.challenge:
        startColor = AppStyles.roseRed;
        endColor = AppStyles.roseRed.withOpacity(0.6);
        backgroundImage = AppMedia.challengeBackground;
        route = "/basic_flow_widget";
        break;
    }

    return Animate(
      delay: AppStyles.getStaggeredDelay(index),
      effects: AppStyles.cardEntranceEffects2(),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 310,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.none,
            scale: 2.5,
            alignment: const Alignment(0.9, -0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                practiceType,
                style: AppStyles.paragraph1,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                children: [
                  Flexible(
                    flex: 6,
                    child: Text(
                      desc,
                      style: AppStyles.paragraph1.copyWith(fontSize: 18),
                    ),
                  ),
                  const Spacer(flex: 4),
                ],
              ),
              const SizedBox(
                height: 35,
              ),
              if (cardType == CardType.challenge)
                Column(
                  children: [
                    StartButton(
                        text: "Addition",
                        color: Colors.green[600],
                        onTap: () => showDialog(
                              context: context,
                              builder: (context) => const MathModeDialog(
                                mode: MathMode.addition,
                              ),
                            )),
                    const SizedBox(height: 16),
                    StartButton(
                        text: "Subtraction",
                        color: Colors.orange[600],
                        onTap: () => showDialog(
                              context: context,
                              builder: (context) => const MathModeDialog(
                                mode: MathMode.subtraction,
                              ),
                            )),
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
    );
  }
}
