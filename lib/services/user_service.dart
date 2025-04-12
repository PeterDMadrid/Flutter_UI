import 'dart:convert';
import 'package:flutter_hands/base/res/global/global_variables.dart';
import 'package:flutter_hands/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String _baseUrl = 'http://${GlobalVariables.server}/api/auth';
  static const _storage = FlutterSecureStorage();

  static Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }
  
  Future<UserModel> fetchUserData(String username) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/users/by-username/$username/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );
    print('Raw API response: ${response.body}');

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user data');
    }
  }
}
