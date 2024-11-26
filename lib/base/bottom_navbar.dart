import 'package:flutter/material.dart';
import 'package:flutter_hands/services/auth_service.dart';
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
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await AuthService.getUserData();
      if (!mounted) return;
      
      if (userData != null) {
        setState(() {
          username = userData['username'];
          profilePicture = userData['profile_picture'] != null
          ? 'http://127.0.0.1:8000${userData['profile_picture']['image']}'
          : null;
          currentLevel = userData['level'];
          isLoading = false;
        });
        print('Authenticated as: $username');
      } else {
        await AuthService.clearAuthData();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (error) {
      print('Error loading user data: $error');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appScreens = [
      const LessonScreen(),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: const Color(0xFF526400),
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
    );
  }
}
