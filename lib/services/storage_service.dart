import 'dart:convert';
import '../models/user.dart';

class StorageService {
  // In-memory storage (replace with shared_preferences in production)
  static final Map<String, String> _storage = {};

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  // Token operations
  static Future<void> saveToken(String token) async {
    _storage[_tokenKey] = token;
  }

  static Future<String?> getToken() async {
    return _storage[_tokenKey];
  }

  static Future<void> removeToken() async {
    _storage.remove(_tokenKey);
  }

  // User operations
  static Future<void> saveUser(User user) async {
    _storage[_userKey] = json.encode(user.toJson());
  }

  static Future<User?> getUser() async {
    final userJson = _storage[_userKey];
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  static Future<void> removeUser() async {
    _storage.remove(_userKey);
  }

  // General operations
  static Future<void> saveString(String key, String value) async {
    _storage[key] = value;
  }

  static Future<String?> getString(String key) async {
    return _storage[key];
  }

  static Future<void> remove(String key) async {
    _storage.remove(key);
  }

  static Future<void> clearAll() async {
    _storage.clear();
  }

  static Future<bool> containsKey(String key) async {
    return _storage.containsKey(key);
  }
}