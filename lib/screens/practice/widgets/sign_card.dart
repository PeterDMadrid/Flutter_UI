import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/widgets/start_button.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class SignCard extends StatelessWidget {
  const SignCard({
    super.key,
    required this.practiceType,
    required this.isRoseRed,
    required this.desc,
  });
  final String practiceType;
  final String desc;
  final bool isRoseRed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 310,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isRoseRed ? AppStyles.roseRed : AppStyles.lavender.withOpacity(0.6),
            isRoseRed ? AppStyles.roseRed.withOpacity(0.6) : AppStyles.lavender,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(isRoseRed
              ? AppMedia.practiceSignBackground
              : AppMedia.practiceRecognitionBackground),
          fit: BoxFit.none,
          scale: 2.5,
          alignment: const Alignment(0.9, -0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              practiceType,
              style: AppStyles.headLineStyle2,
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
                    style: AppStyles.headLineStyle2.copyWith(fontSize: 18),
                  ),
                ),
                const Spacer(flex: 4),
              ],
            ),
            const SizedBox(
              height: 35,
            ),
            const Center(child: StartButton()),
          ],
        ),
      ),
    );
  }
}
