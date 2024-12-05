import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/animations/reading_effect.dart';

class Introduction extends StatelessWidget {
  const Introduction({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          ReadingEffect(
            text: "Hello there, $name",
            style: AppStyles.headLineStyle2,
            effect: AnimationEffect.typewriter,
          )
        ]),
      ),
    );
  }
}
