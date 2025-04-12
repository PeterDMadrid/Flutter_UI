import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/widgets/heading.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/base/widgets/drawer_button_menu.dart';
import 'package:flutter_hands/models/user_model.dart';
import 'package:flutter_hands/screens/lesson/widgets/side_menu.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';
import 'package:flutter_hands/services/user_service.dart';

class PracticeScreen extends StatefulWidget {
  const PracticeScreen({super.key, required this.name});

  final String name;
  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  late Future<UserModel> futureUser;
  final UserService userService = UserService();

  @override
  void initState() {
    super.initState();
    futureUser = userService.fetchUserData(widget.name);
  }

  @override
  Widget build(BuildContext context) {
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
                  return Stack(children: [
                    buildpracticeScreen(),
                    const DrawerButtonMenu(),
                    if (!user.progress.mathlesson) buildLockScreen()
                  ]);
                } else {
                  return Center(child: Text('No data available'));
                }
              },
            ),
          );
        });
  }

  Widget buildpracticeScreen() {
    return const SafeArea(
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
    );
  }

  Widget buildLockScreen() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    AppMedia.lock,
                    width: 80,
                    height: 80,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Complete Math Lesson first",
                    style: AppStyles.headLineStyle1.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.8),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
