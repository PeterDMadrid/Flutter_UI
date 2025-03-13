import 'package:flutter/material.dart';
import 'package:flutter_hands/base/bottom_navbar.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/screens/auth/login_screen.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/global/user_session.dart';

class CheckAuth extends StatefulWidget {
  const CheckAuth({super.key});

  @override
  State<CheckAuth> createState() => _CheckAuthState();
}

class _CheckAuthState extends State<CheckAuth> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final userData = await AuthService.getUserData();
      
      if (!mounted) return;

      if (userData != null) {
        UserSession().setUserData(userData);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBar(initialUserData: userData)
          ),
        );
      } else {
        await AuthService.clearAuthData();
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } catch (error) {
      print('Error checking auth status: $error');
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
    );
  }
}
