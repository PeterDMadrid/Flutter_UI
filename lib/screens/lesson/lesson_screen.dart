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
                const LessonCard(lessonName:"Number 0" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
                const LessonCard(lessonName:"Number 1" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
                const LessonCard(lessonName:"Number 2" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
                const LessonCard(lessonName:"Number 3" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
                const LessonCard(lessonName:"Number 4" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
                const LessonCard(lessonName:"Number 5" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
                const LessonCard(lessonName:"Number 6" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
                const LessonCard(lessonName:"Number 7" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
                const LessonCard(lessonName:"Number 8" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
                const LessonCard(lessonName:"Number 9" ,  lessonIcon: AppMedia.practiceRecognitionBackground),
                const SizedBox(height: 20,),
              ],
            ),
          )
        ],
      ),
    );
  }
}
