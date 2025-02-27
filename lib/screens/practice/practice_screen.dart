import 'package:flutter/material.dart';
import 'package:flutter_hands/base/widgets/heading.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: const SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading(headingText: "Master Your Signs"),
                SignCard(
                  index: 0,
                  practiceType: "Signing",
                  desc:
                      "Boost your skills and have a blast by magically signing the awesome numbers that pop up on the screen!",
                  cardType: CardType.signing,
                ),
                SizedBox(height: 20),
                SignCard(
                  index: 1,
                  practiceType: "Recognition",
                  desc:
                      "Identify those sneaky sign language numbers that are hiding on the screen",
                  cardType: CardType.recognition,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
