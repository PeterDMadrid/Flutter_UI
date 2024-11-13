import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/lesson/widgets/lesson_card.dart';
import 'package:flutter_hands/base/res/media.dart';


class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key});

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
                Text("Learn Your Signs", style: AppStyles.headLineStyle1),
                const SizedBox(height: 20,),
                const LessonCard(
                  lessonTitle:"Introduction" ,
                  lessonSubtitle: "Numbers 0-9", 
                  lessonIcon: AppMedia.practiceRecognitionBackground
                ),
                const SizedBox(height: 20,),
                const LessonCard(
                  lessonTitle:"Two Digits" ,  
                  lessonSubtitle: "Numbers 10-99", 
                  lessonIcon: AppMedia.practiceRecognitionBackground
                ),
                const SizedBox(height: 20,),
                const LessonCard(
                  lessonTitle:"Examples" ,  
                  lessonSubtitle: "Numbers 1-99", 
                  lessonIcon: AppMedia.practiceRecognitionBackground
                ),
                const SizedBox(height: 20,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
