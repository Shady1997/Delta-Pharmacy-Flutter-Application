import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  static String? _authToken;
  static User? _currentUser;

  static String? get authToken => _authToken;
  static User? get currentUser => _currentUser;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _authToken = data['data']['token'];
          _currentUser = User.fromJson(data['data']);

          // Save token and user to storage
          await StorageService.saveToken(_authToken!);
          await StorageService.saveUser(_currentUser!);

          return {'success': true, 'data': data};
        } else {
          return {'success': false, 'error': data['message'] ?? 'Login failed'};
        }
      } else {
        return {'success': false, 'error': 'Invalid credentials'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        if (data['success'] == true) {
          _authToken = data['data']['token'];
          _currentUser = User.fromJson(data['data']);

          await StorageService.saveToken(_authToken!);
          await StorageService.saveUser(_currentUser!);

          return {'success': true, 'data': data};
        }
      }
      return {'success': false, 'error': 'Registration failed'};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  static Future<void> logout() async {
    _authToken = null;
    _currentUser = null;
    await StorageService.clearAll();
  }

  static Future<bool> isLoggedIn() async {
    if (_authToken != null && _currentUser != null) return true;

    final token = await StorageService.getToken();
    if (token != null) {
      _authToken = token;
      _currentUser = await StorageService.getUser();
      return _currentUser != null;
    }

    return false;
  }

  static Future<User?> getProfile() async {
    if (_authToken == null) return null;

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profile),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _currentUser = User.fromJson(data['data']);
          await StorageService.saveUser(_currentUser!);
          return _currentUser;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };
  }

  static void setAuthToken(String token) {
    _authToken = token;
  }

  static void setCurrentUser(User user) {
    _currentUser = user;
  }
}