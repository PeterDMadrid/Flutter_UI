import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/widgets/heading.dart';
import 'package:flutter_hands/base/widgets/tip_box.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/theme_provider.dart';
import 'package:flutter_hands/base/widgets/drawer_button_menu.dart';
import 'package:flutter_hands/models/user_model.dart';
import 'package:flutter_hands/screens/lesson/widgets/side_menu.dart';
import 'package:flutter_hands/screens/practice/widgets/sign_card.dart';
import 'package:flutter_hands/services/user_service.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.name});

  final String name;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
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
                      buildChallenge(screenHeight, isDarkMode),
                      const TipBox(
                        staggerDelay: 3,
                      ),
                      const DrawerButtonMenu(),
                      if (!user.progress.mathlesson) buildLockScreen()
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

  Widget buildChallenge(double screenHeight, isDarkMode) {
    return ListView(
      children: [
        Container(
            decoration:
                BoxDecoration(color: AppStyles.getBackgroundColor(isDarkMode)),
            height: screenHeight,
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading(headingText: "Put Your Skills to the Test"),
                SignCard(
                    practiceType: "Challenge",
                    cardType: CardType.challenge,
                    desc:
                        "Take your skills to the next level! Tackle tricky numbers and beat the clock in this ultimate sign language showdown!")
              ],
            ))
      ],
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
