import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/media.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  final int level;
  final String? profilePicture;

  const ProfileScreen({
    super.key, 
    required this.name, 
    required this.level, 
    required this.profilePicture
  });

  Future<void> logoutUser(BuildContext context) async {
    try {
      final success = await AuthService.logout();
      if (success) {
        Navigator.pushReplacementNamed(context, '/auth_check');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Widget buildProfileImage() {
    if (profilePicture != null) {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            profilePicture!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                AppMedia.defaultProfilePhoto,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      );
    } else {
      return const CircleAvatar(
        radius: 50,
        backgroundImage: AssetImage(AppMedia.defaultProfilePhoto),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: AppStyles.backgroundColor),
        height: screenHeight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    buildProfileImage(),
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
      ),
    );
  }
}
