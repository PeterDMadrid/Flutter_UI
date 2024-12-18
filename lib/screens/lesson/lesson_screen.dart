import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/lesson/widgets/lesson_card.dart';
import 'package:flutter_hands/screens/lesson/modules/examples_screen.dart';
import 'package:flutter_hands/screens/lesson/modules/two_digits_screen.dart';
import 'package:flutter_hands/screens/lesson/modules/introduction/Introduction_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: ListView(
        children: [
          Container(
            height: screenHeight,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text("Learn Your Signs", style: AppStyles.headLineStyle1),
                const SizedBox(
                  height: 20,
                ),
                LessonCard(
                  lessonTitle: "Introduction",
                  lessonSubtitle: "Numbers 0-9",
                  lessonIcon: AppMedia.practiceRecognitionBackground,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Introduction(name: name,)),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                LessonCard(
                  lessonTitle: "Two Digits",
                  lessonSubtitle: "Numbers 10-99",
                  lessonIcon: AppMedia.practiceRecognitionBackground,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TwoDigitsScreen()),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                LessonCard(
                  lessonTitle: "Examples",
                  lessonSubtitle: "Numbers 1-99",
                  lessonIcon: AppMedia.practiceRecognitionBackground,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ExamplesScreen()),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
