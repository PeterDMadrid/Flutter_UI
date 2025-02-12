import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) { 
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: ListView(
        children: [
          Container(
            decoration: BoxDecoration(color: AppStyles.backgroundColor),
            height: screenHeight,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text("Challenge Module", style: AppStyles.headLineStyle1,),
                const SizedBox(height: 20),
                const SignCard(practiceType: "Challenge", cardType: CardType.challenge, desc: "Take your skills to the next level! Tackle tricky numbers and beat the clock in this ultimate sign language showdown!")
              ],
            )
          )
        ],
      ),
    );
  }
}
