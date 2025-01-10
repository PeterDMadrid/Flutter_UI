import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/screens/lesson/lesson_screen.dart';
import 'package:flutter_hands/screens/profile/profile_screen.dart';
import 'package:flutter_hands/screens/practice/practice_screen.dart';
import 'package:flutter_hands/screens/challenge/challenge_screen.dart';

class BottomNavBar extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;

  const BottomNavBar({
    super.key,
    this.initialUserData,
  });

  @override
  State createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  String? username;
  String? profilePicture;
  int scoreRecognition = 0;
  int currentLevel = 1;
  bool isLoading = false;
  var _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialUserData != null) {
      _initializeUserData(widget.initialUserData!);
    }
  }

  void _initializeUserData(Map<String, dynamic> userData) {
    setState(() {
      username = userData['username'];
      profilePicture = userData['profile_picture'] != null
          ? 'http://127.0.0.1:8000${userData['profile_picture']['image']}'
          : null;
      currentLevel = userData['level'];
      scoreRecognition = userData['score'] != null ? userData['score']['recognition'] : 0;

    print('----------------------------------');
    print('Username: $username');
    print('Profile Picture: $profilePicture');
    print('Current Level: $currentLevel');
    print('Score Recognition: $scoreRecognition');

    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appScreens = [
      LessonScreen(name: username ?? "Guest",),
      const PracticeScreen(),
      const ChallengeScreen(),
      ProfileScreen(
        name: username ?? "Guest",
        level: currentLevel,
        profilePicture: profilePicture,
      ),
    ];

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: appScreens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppStyles.headlineColor.withOpacity(0.1), 
              blurRadius: 5,
              offset: const Offset(0, -1), 
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: AppStyles.backgroundColor,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: const Color.fromARGB(255, 124, 160, 179),
          unselectedItemColor: const Color.fromARGB(255, 74, 102, 116),
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: "Lesson",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center),
              label: "Practice",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outlined),
              label: "Challenge",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
