import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/base/bottom_navbar.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/res/styles/app_styles.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_hands/screens/auth/widgets/profile_creation';
import 'package:flutter_hands/screens/auth/widgets/profile_selection.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> savedProfiles = [];
  List<Map<String, dynamic>> profilePictures = [];
  bool isCreatingNewProfile = false;
  
  final TextEditingController usernameController = TextEditingController();
  int? selectedProfilePictureId;

  @override
  void initState() {
    super.initState();
    fetchProfilePictures();
    loadSavedProfiles();
  }

  Future<void> loadSavedProfiles() async {
    try {
      final profilesJson = await storage.read(key: 'saved_profiles');
      if (profilesJson != null) {
        setState(() {
          savedProfiles = List<Map<String, dynamic>>.from(
            jsonDecode(profilesJson),
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading saved profiles: $e');
    }
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    try {
      final updatedProfiles = [...savedProfiles, profile];
      if (updatedProfiles.length <= 6) {
        await storage.write(
          key: 'saved_profiles',
          value: jsonEncode(updatedProfiles),
        );
        setState(() {
          savedProfiles = updatedProfiles;
        });
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
    }
  }

  Future<void> fetchProfilePictures() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/auth/profile-pictures/'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          profilePictures = data.map((e) => {
            "id": e['id'],
            "name": e['name'],
            "image": 'http://127.0.0.1:8000${e['image']}',
          }).toList();
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching profile pictures: $error')),
        );
      }
    }
  }

  Future<void> createNewProfile() async {
    final username = usernameController.text;
    if (username.isEmpty || selectedProfilePictureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username and select a profile picture'),
        ),
      );
      return;
    }

    try {
      await AuthService.register(username, selectedProfilePictureId!);
      final userData = await AuthService.getUserData();
      
      if (userData != null) {
        await saveProfile({
          'username': username,
          'profilePictureId': selectedProfilePictureId,
          'userData': userData,
        });

        if (!mounted) return;
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BottomNavBar(initialUserData: userData),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating profile: $error')),
      );
    }
  }

  Future<void> loginWithProfile(Map<String, dynamic> profile) async {
  try {
    final result = await AuthService.login(profile['username']);
    if (result != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BottomNavBar(initialUserData: result['user']),
        ),
      );
    } else {
      throw Exception('Login failed.');
    }
  } catch (error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error logging in: $error')),
    );
  }
}

@override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    
    final double profileImageSize = isSmallScreen ? 80 : screenSize.width * 0.25;
    final double gridSpacing = isSmallScreen ? 8.0 : 16.0;
    final double fontSize = isSmallScreen ? 14.0 : 16.0;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenSize.width * 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Users",
                style: AppStyles.headLineStyle1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenSize.height * 0.04),
              if (!isCreatingNewProfile)
                ProfileSelection(
                  profileImageSize: profileImageSize,
                  gridSpacing: gridSpacing,
                  fontSize: fontSize,
                  savedProfiles: savedProfiles,
                  onProfileSelect: loginWithProfile,
                  onAddProfileTap: () => setState(() => isCreatingNewProfile = true),
                )
              else
                ProfileCreation(
                  usernameController: usernameController,
                  screenWidth: screenSize.width,
                  screenHeight: screenSize.height,
                  fontSize: fontSize,
                  gridSpacing: gridSpacing,
                  profilePictures: profilePictures,
                  selectedProfilePictureId: selectedProfilePictureId,
                  onProfilePictureSelect: (id) => setState(() => selectedProfilePictureId = id),
                  onCreateProfile: createNewProfile,
                  onCancel: () {
                    setState(() {
                      isCreatingNewProfile = false;
                      usernameController.clear();
                      selectedProfilePictureId = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
