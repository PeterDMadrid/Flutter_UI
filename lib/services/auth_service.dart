import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _baseUrl = 'http://127.0.0.1:8000/api/auth';
  static const _storage = FlutterSecureStorage();

  // Store both token and user data
  static Future<void> saveAuthData(
      String token, Map<String, dynamic> userData) async {
    await _storage.write(key: 'token', value: token);
    await _storage.write(key: 'userData', value: jsonEncode(userData));
  }

  static Future<void> clearAuthData() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userData');
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataStr = await _storage.read(key: 'userData');
      final token = await getToken();

      if (userDataStr != null && token != null) {
        // Verify the token is still valid
        final isValid = await checkAuthentication();
        if (!isValid) {
          await clearAuthData();
          return null;
        }

        return jsonDecode(userDataStr);
      }
    } catch (e) {
      print('Error getting user data: $e');
    }
    return null;
  }

  static Future<bool> checkAuthentication() async {
    final token = await getToken();
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/check-authentication/'),
        headers: {'Authorization': 'Token $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>?> login(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login/'),
        body: {'username': username},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveAuthData(data['token'], data['user']);
        return data;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> register(
      String username, int profilePictureId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register/'),
        body: {
          'username': username,
          'profile_picture_id': profilePictureId.toString(),
        },
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await saveAuthData(data['token'], data['user']);
        return data;
      }
    } catch (e) {
      print('Registration error: $e');
    }
    return null;
  }

  static Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse('$_baseUrl/logout-user/'),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode == 200) {
        await clearAuthData();
        return true;
      }
    } catch (e) {
      print('Logout error: $e');
    }
    return false;
  }
}
