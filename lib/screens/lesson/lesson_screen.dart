import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/lesson/widgets/lesson_card.dart';
import 'package:flutter_hands/screens/lesson/modules/two_digits_screen.dart';
import 'package:flutter_hands/screens/lesson/modules/math_lesson_screen.dart';
import 'package:flutter_hands/screens/lesson/modules/introduction/Introduction_screen.dart';
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.name});
  final String name;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  @override
  void initState() {
    super.initState();
    print("hello");
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('MatHands'),
        backgroundColor:Color.fromARGB(255, 35, 73, 104),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
           const DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 35, 73, 104),
              ),
              child: Text(
                'Profile pic/progress here',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Go to profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Progress'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('logout'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
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
                  index: 0,
                  lessonTitle: "Introduction",
                  lessonSubtitle: "Numbers 0-9",
                  lessonIcon: AppMedia.practiceRecognitionBackground,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Introduction(
                                name: widget.name,
                              )),
                    );
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                LessonCard(
                  index: 1,
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
                  index: 2,
                  lessonTitle: "Math Lessons",
                  lessonSubtitle: "Introducing Operations",
                  lessonIcon: AppMedia.practiceRecognitionBackground,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MathLessonScreen()),
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
