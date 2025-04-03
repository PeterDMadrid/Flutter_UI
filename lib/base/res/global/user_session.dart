import 'package:flutter/material.dart';
import 'package:flutter_hands/services/auth_service.dart';
import 'package:flutter_hands/base/res/global/global_variables.dart';

class UserSession extends ChangeNotifier {
  static final UserSession _instance = UserSession._internal();

  factory UserSession() => _instance;

  UserSession._internal();

  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _error;

  // Getters for status
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _userData != null;

  // Data getters
  String get username => _userData?['username'] ?? 'Guest';
  String? get profilePicture => _userData?['profile_picture'] != null
      ? 'http://${GlobalVariables.server}${_userData!['profile_picture']['image']}'
      : null;
  int get currentLevel => _userData?['level'] ?? 0;
  int get scoreRecognition => _userData?['score']?['recognition'] ?? 0;

  // Initialize user data - call this after login or app start
  Future<void> initializeUserData(Map<String, dynamic>? data) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (data != null) {
        _userData = data;
        _error = null;
      } else {
        // If no data provided, try to fetch from API or storage
        // This would be your implementation to get user data
        _error = 'No user data provided';
      }
    } catch (e) {
      _error = 'Failed to initialize user data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setUserData(Map<String, dynamic> data) {
    _userData = data;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  // Clear user data on logout
  void clearUserData() {
    _userData = null;
    notifyListeners();
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      final success = await AuthService.logout();
      if (success && context.mounted) {
        clearUserData();
        Navigator.pushReplacementNamed(context, '/auth_check');
      }
    } catch (e) {
      print('Error during logout: $e');
    }
  }
}
