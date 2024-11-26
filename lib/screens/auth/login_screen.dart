import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> profilePictures = [];
  int? selectedProfilePictureId;

  @override
  void initState() {
    super.initState();
    fetchProfilePictures();
  }

  Future<void> fetchProfilePictures() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/auth/profile-pictures/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          profilePictures = data.map((e) => {
                "id": e['id'],
                "image": e['image'],
              }).toList();
        });
      } else {
        throw Exception('Failed to load profile pictures');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching profile pictures: $error')),
      );
    }
  }

 Future<void> createUser() async {
  final username = usernameController.text;
  if (username.isEmpty || selectedProfilePictureId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enter a username and select a profile picture')),
    );
    return;
  }

  try {
    final data = await AuthService.register(username, selectedProfilePictureId!);
    if (data != null) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/bottom_navbar');
    } else {
      throw Exception('Failed to create user');
    }
  } catch (error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error creating user: $error')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Enter your username'),
            ),
            const SizedBox(height: 16),
            profilePictures.isEmpty
                ? const CircularProgressIndicator()
                : GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: profilePictures.length,
                    itemBuilder: (context, index) {
                      final profile = profilePictures[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedProfilePictureId = profile['id'];
                          });
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            ClipOval(
                              child: Image.network(
                                profile['image'],
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error, color: Colors.red);
                                },
                              ),
                            ),
                            if (selectedProfilePictureId == profile['id'])
                              const Icon(Icons.check_circle, color: Colors.green, size: 30),
                          ],
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: createUser,
              child: const Text('Create User'),
            ),
          ],
        ),
      ),
    );
  }
}
