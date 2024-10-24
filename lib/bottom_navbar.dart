import 'package:flutter/material.dart';
import 'package:fluentui_icons/fluentui_icons.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final appScreens = [
    const Center(child: Text("Learn")),
    const Center(child: Text("Practice")),
    const Center(child: Text("Challenge")),
    const Center(child: Text("Profile")),
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
            icon: Icon(Icons.bookmark_outline_sharp), // Default icon for Learn
            activeIcon: Icon(Icons.bookmark_outlined), // Active icon for Learn
            label: "Learn",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), // Default icon for Practice
            activeIcon: Icon(Icons.fitness_center), // Active icon for Practice
            label: "Practice",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outlined), // Default icon for Challenge
            activeIcon: Icon(Icons.play_circle_rounded), // Active icon for Challenge
            label: "Challenge",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), // Icon for Profile
            activeIcon: Icon(Icons.person), // Active icon for Profile
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
