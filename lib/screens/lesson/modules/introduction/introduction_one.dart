import 'package:flutter/material.dart';
import 'package:flutter_hands/base/bottom_navbar.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class IntroductionOne extends StatefulWidget {
  const IntroductionOne({super.key, required this.name});

final String name;

  @override
  State<IntroductionOne> createState() => _IntroductionOneState();
}

class _IntroductionOneState extends State<IntroductionOne> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.backgroundColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.home_filled), 
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) =>  const BottomNavBar()),
            );
          },
        ),
      ),
    );
  }
}
