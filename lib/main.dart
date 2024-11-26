import 'package:flutter/material.dart';
import 'package:flutter_hands/splash_screen.dart';
import 'package:flutter_hands/base/bottom_navbar.dart';
import 'package:flutter_hands/screens/auth/login_screen.dart';
import 'package:flutter_hands/screens/practice/signing_screen.dart';
import 'package:flutter_hands/screens/practice/recognition_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Splash Screen Demo',
      theme: ThemeData(
        fontFamily: 'Poppins'
      ),
      routes: {
        "/" : (context) => const SplashScreen(),
        "/login": (context) => const LoginScreen(),
        "/signing_screen" : (context) => const SigningScreen(),
        "/recognition_screen" : (context) => const RecognitionScreen(),
        "/bottom_navbar": (context) => const BottomNavBar(),
      }
    );
  }
}
 