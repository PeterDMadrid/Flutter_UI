import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: SafeArea(
        child: Padding( 
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text("Master Your Signs", style: AppStyles.headLineStyle1),
              const SizedBox(
                height: 20,
              ),
              const SignCard(
                practiceType: "Signing",
                desc: "Boost your skills and have a blast by magically signing the awesome numbers that pop up on the screen!",
                cardType: CardType.signing,
              ),
              const SizedBox(
                height: 20,
              ),
              const SignCard(
                practiceType: "Recognition",
                desc: "Identify those sneaky sign language numbers that are hiding on the screen",
                cardType: CardType.recognition,
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
