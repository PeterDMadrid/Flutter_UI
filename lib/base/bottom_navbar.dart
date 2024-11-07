import 'package:flutter/material.dart';
import 'package:flutter_hands/screens/practice/practice_screen.dart';
import 'package:flutter_hands/screens/profile/profile_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final appScreens = [
    const Center(child: Text("Learn")),
    const PracticeScreen(),
    const Center(child: Text("Challenge")),
    const ProfileScreen(),
  ];

  var _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: appScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: const Color(0xFF526400),
        showSelectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline_sharp), 
            activeIcon: Icon(Icons.bookmark_outlined), 
            label: "Learn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            activeIcon: Icon(Icons.fitness_center),
            label: "Practice",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outlined),
            activeIcon: Icon(Icons.play_circle_rounded),
            label: "Challenge",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
