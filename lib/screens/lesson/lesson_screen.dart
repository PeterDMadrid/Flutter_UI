import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/widgets/heading.dart';
import 'package:flutter_hands/base/widgets/tip_box.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/base/widgets/drawer_button_menu.dart';
import 'package:flutter_hands/screens/lesson/widgets/side_menu.dart';
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
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Scaffold(
              backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
              endDrawer: const SideMenu(),
              body: Stack(
                children: [
                  buildLessonCards(screenHeight),
                  const TipBox(staggerDelay: 1),
                  const DrawerButtonMenu(),
                ],
              ));
        });
  }

  Widget buildLessonCards(double screenHeight) {
    return ListView(
      children: [
        Container(
          height: screenHeight,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Heading(headingText: "Learn Your Signs"),
              LessonCard(
                index: 0,
                lessonTitle: "Introduction",
                lessonSubtitle: "Numbers 0-9",
                lessonIcon: AppMedia.introductionPoster,
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
                lessonIcon: AppMedia.twoDigitsPoster,
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
                lessonIcon: AppMedia.mathLessonPoster,
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
    );
  }
}
