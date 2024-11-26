import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  final int level;
  final String? profilePicture;

  const ProfileScreen({super.key, required this.name, required this.level, required this.profilePicture
  
  });
    Future<void> logoutUser(BuildContext context) async {
    try {
      final success = await AuthService.logout();
      if (success) {
        Navigator.pushReplacementNamed(context, '/bottom_navbar');
        print('User logged out successfully.');
      } else {
        print('Logout failed.');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 20),
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(AppMedia.defaultProfilePhoto),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: AppStyles.headLineStyle1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Level $level",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppStyles.lavender,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_outlined),
                    onPressed: () => logoutUser(context),
                  )
                ],
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
