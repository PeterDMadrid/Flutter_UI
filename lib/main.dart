import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hands/splash_screen.dart';
import 'package:flutter_hands/base/bottom_navbar.dart';
import 'package:flutter_hands/screens/auth/check_auth.dart';
import 'package:flutter_hands/screens/auth/login_screen.dart';
import 'package:flutter_hands/screens/practice/signing_screen.dart';
import 'package:flutter_hands/screens/challenge/addition_screen.dart';
import 'package:flutter_hands/screens/practice/recognition_screen.dart';
import 'package:flutter_hands/screens/challenge/subtraction_screen.dart';

// Declare as global variable
late List<CameraDescription> globalCameras;
String baseUrl = "192.168.1.10:8000";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    globalCameras = await availableCameras();
  } catch (e) {
    debugPrint('Error initializing cameras: $e');
    globalCameras = [];
  }

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
        "/": (context) => const SplashScreen(),
        "/login": (context) => const LoginScreen(),
        "/signing_screen": (context) => const SigningScreen(),
        "/recognition_screen": (context) => const RecognitionScreen(),
        "/addition_screen": (context) => const AdditionScreen(),
        "/subtraction_screen": (context) => const SubtractionScreen(),
        "/bottom_navbar": (context) => const BottomNavBar(),
        "/auth_check": (context) => const CheckAuth()
      }
    );
  }
}
