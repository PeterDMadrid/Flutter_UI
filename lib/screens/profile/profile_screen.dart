import 'package:flutter/material.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';

class ProfileScreen extends StatelessWidget {
  final String name;
  
  const ProfileScreen({super.key, required this.name});

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
                    backgroundImage: AssetImage('assets/profile.jpg'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: AppStyles.headLineStyle1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Level 1',
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
