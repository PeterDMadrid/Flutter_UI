import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(  // Stack to overlay the edit button
          children: [
            Center( // Wrap the Column with the Center widget to center content
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Ensures horizontal centering of the children
                children: <Widget>[
                  const SizedBox(height: 20), // Space for the edit button
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/profile.jpg'), // Replace with your image path
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'CJ Madrid',
                    style: AppStyles.headLineStyle1, // Applying custom headline style for the name
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level 1',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppStyles.lavender, // Using custom lavender color for the job title
                    ),
                  ),
                ],
              ),
            ),
            Positioned(  // Position the edit button on the left side
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // Handle the editing action here
                  print("Edit Profile Button Pressed");
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
