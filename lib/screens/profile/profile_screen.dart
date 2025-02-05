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
    required this.profilePicture,
  });

  Future<void> logoutUser (BuildContext context) async {
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
      body: SafeArea( // Wrap the body with SafeArea
        child: Container(
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
                      // Center the Row containing the profile image
                      buildProfileImage(),
                      const SizedBox(height: 16),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: AppStyles.headLineStyle1,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Level $level",
                        style: AppStyles.headLineStyle1.copyWith(
                          fontSize: 24, // Make the font size larger
                          color: AppStyles.khaki, // Use yellow color from app styles
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Scores Table
                      Table(
                        border: const TableBorder(
                          top: BorderSide(color: Colors.white),
                          bottom: BorderSide(color: Colors.white),
                          left: BorderSide(color: Colors.white),
                          right: BorderSide(color: Colors.white),
                          horizontalInside: BorderSide(color: Colors.white),
                          verticalInside: BorderSide(color: Colors.white),
                        ),
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(1),
                        },
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Quiz',
                                    style: AppStyles.headLineStyle2.copyWith(color: Colors.white, fontSize: 24),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Scores',
                                    style: AppStyles.headLineStyle2.copyWith(color: Colors.white, fontSize: 24),
                                  ),
                                ),
                              ), // Empty cell for alignment
                            ],
                          ),
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Recognition Practice', style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                              Center( // Center the score in the cell
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('1', style: TextStyle(color: Colors.white, fontSize: 18)),
                                ),
                              ),
                            ],
                          ),
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Signing Practice', style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                              Center( // Center the score in the cell
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('1', style: TextStyle(color: Colors.white, fontSize: 18)),
                                ),
                              ),
                            ],
                          ),
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Recognition Challenge', style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                              Center( // Center the score in the cell
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('1', style: TextStyle(color: Colors.white, fontSize: 18)),
                                ),
                              ),
                            ],
                          ),
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Signing Challenge', style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                              Center( // Center the score in the cell
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('1', style: TextStyle(color: Colors.white, fontSize: 18)),
                                ),
                              ),
                            ],
                          ),
                          const TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Total Progress', style: TextStyle(color: Colors.white, fontSize: 18)),
                              ),
                              Center( // Center the score in the cell
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('5%', style: TextStyle(color: Colors.white, fontSize: 18)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white), // Set icon color to white
                    onSelected: (value) {
                      if (value == 'edit') {
                        // Implement edit functionality here
                      } else if (value == 'logout') {
                        logoutUser (context);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Text('Edit Profile', style: TextStyle(color: Colors.black)), // Change color as needed
                        ),
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Text('Logout', style: TextStyle(color: Colors.black)), // Change color as needed
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
