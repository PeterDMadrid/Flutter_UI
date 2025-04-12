import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/widgets/heading.dart';
import 'package:flutter_hands/base/widgets/tip_box.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/base/widgets/drawer_button_menu.dart';
import 'package:flutter_hands/models/user_model.dart';
import 'package:flutter_hands/screens/lesson/widgets/side_menu.dart';
import 'package:flutter_hands/screens/lesson/widgets/lesson_card.dart';
import 'package:flutter_hands/screens/lesson/modules/two_digits_screen.dart';
import 'package:flutter_hands/screens/lesson/modules/math_lesson_screen.dart';
import 'package:flutter_hands/screens/lesson/modules/introduction/Introduction_screen.dart';
import 'package:flutter_hands/services/user_service.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.name});
  final String name;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Future<UserModel> futureUser;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    futureUser = userService.fetchUserData(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return ValueListenableBuilder(
        valueListenable: ThemeManager().isDarkModeNotifier,
        builder: (context, isDarkMode, child) {
          return Scaffold(
            backgroundColor: AppStyles.getBackgroundColor(isDarkMode),
            endDrawer: const SideMenu(),
            body: FutureBuilder<UserModel>(
              future: futureUser,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  UserModel user = snapshot.data!;
                  return Stack(
                    children: [
                      buildLessonCards(screenHeight, user.progress.introduction,
                          user.progress.twodigit, user.progress.mathlesson),
                      const TipBox(staggerDelay: 1),
                      const DrawerButtonMenu(),
                    ],
                  );
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          );
        });
  }

  Widget buildLessonCards(
      double screenHeight, isIntroDone, isTwoDigitDone, isMathLessonDone) {
    return ListView(
      children: [
        Container(
          height: screenHeight,
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Heading(headingText: "Learn Your Signs"),
              LessonCard(
                index: 0,
                lessonTitle: "Introduction",
                lessonSubtitle: "Numbers 0-9",
                lessonIcon: AppMedia.introductionPoster,
                isPrevDone: true,
                preReq: "None",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Introduction(
                        name: widget.name,
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      futureUser = userService.fetchUserData(widget.name);
                    });
                  }
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
                isPrevDone: isIntroDone,
                preReq: "Introduction lesson",
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TwoDigitsScreen(
                        name: widget.name,
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      futureUser = userService.fetchUserData(widget.name);
                    });
                  }
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
                isPrevDone: isTwoDigitDone,
                preReq: "Two Digits lesson",
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
