import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text("Master Your Signs", style: AppStyles.headLineStyle1),
                const SizedBox(
                  height: 20,
                ),
                const SignCard(text: "Signing", isRoseRed: true),
                const SizedBox(
                  height: 20,
                ),
                const SignCard(text: "Recognition", isRoseRed: false,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
