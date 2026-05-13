import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/screens/auth/check_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to main screen after animation
    Future.delayed(const Duration(milliseconds: 3500), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CheckAuth()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: Stack(children: [
        Positioned(
            child: Image(image: AssetImage(AppMedia.mathandsLogo)),
            left: 40,
            right: 40,
            top: 0,
            bottom: 0),
        Positioned(
          child: Lottie.asset(
            'assets/animations/splash_screen.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          left: 50,
          right: 50,
          bottom: 10,
        ),
      ]),
    );
  }
}
