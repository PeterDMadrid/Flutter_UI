import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_hands/base/res/media.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  final String level;
  
  const ProfileScreen({super.key, required this.name, required this.level});

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
                    backgroundImage: AssetImage(AppMedia.defaultProfilePhoto), // Use the default profile photo from AppMedia
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: AppStyles.headLineStyle1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Level $level", // Use the passed level
                    style: TextStyle(
                      fontSize: 18,
                      color: AppStyles.lavender,
                    ),
                  ),
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
