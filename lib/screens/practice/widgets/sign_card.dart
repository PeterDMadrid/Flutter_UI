import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/widgets/start_button.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

enum CardType { recognition, signing, challenge ,test }

class SignCard extends StatelessWidget {
  const SignCard({
    super.key,
    required this.practiceType,
    required this.desc,
    this.cardType = CardType.recognition,
  });

  final String practiceType;
  final String desc;
  final CardType cardType;

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
        route = "/challenge_screen";
        break;
      case CardType.test:
      startColor = AppStyles.roseRed;
      endColor = AppStyles.roseRed.withOpacity(0.6);
      backgroundImage = AppMedia.challengeBackground;
      route = "/Test_screen";
        break;
    }

    return Container(
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
            Center(
              child: StartButton(
                onTap: () => Navigator.pushNamed(context, route),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
