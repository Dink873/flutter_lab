import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalStorage {
  Future<void> saveUser(Map<String, dynamic> user);
  Future<Map<String, dynamic>?> getUser();
  Future<void> clearUser();
  Future<void> updateUserSettings(Map<String, dynamic> settings);
}

class SharedPrefsStorage implements LocalStorage {
  static const String userKey = 'current_user';

  @override
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(user));
    await prefs.setBool('isLoggedIn', true);
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(userKey);
    if (userStr == null) return null;
    final decoded = jsonDecode(userStr);
    return decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : null;
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userKey);
    await prefs.setBool('isLoggedIn', false);
  }

  @override
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(userKey);
    if (userStr == null) return;
    final decoded = jsonDecode(userStr);
    final user = decoded is Map
        ? Map<String, dynamic>.from(decoded)
        : <String, dynamic>{};
    // Тут settings вже гарантовано Map<String, dynamic>
    user['settings'] = Map<String, dynamic>.from(settings);
    await prefs.setString(userKey, jsonEncode(user));
  }
}
