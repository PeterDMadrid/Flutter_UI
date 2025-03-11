import 'package:flutter/material.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  Map<String, dynamic>? _userData;

  void setUserData(Map<String, dynamic> data) {
    _userData = data;
  }

  String get username => _userData?['username'] ?? 'Guest';
  String? get profilePicture => _userData?['profile_picture'] != null
      ? 'http://${GlobalVariables.server}${_userData!['profile_picture']['image']}'
      : null;
  int get currentLevel => _userData?['level'] ?? 0;
  int get scoreRecognition => _userData?['score']?['recognition'] ?? 0;

  Future<void> logoutUser(BuildContext context) async {
    try {
      final success = await AuthService.logout();
      if (success && context.mounted) {
        Navigator.pushReplacementNamed(context, '/auth_check');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
