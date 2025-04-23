import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_storage.dart';

class SharedPrefsStorage implements LocalStorage {
  final String key = "users";

  @override
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(key);

    List<Map<String, dynamic>> users = [];

    if (usersJson != null) {
      final decoded = jsonDecode(usersJson);
      if (decoded is List) {
        users = decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
    }

    final bool userExists = users.any((u) => u['email'] == user['email']);
    if (!userExists) {
      users.add(user);
      await prefs.setString(key, jsonEncode(users));
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(key);

    if (usersJson == null) return [];

    final decoded = jsonDecode(usersJson);
    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    return [];
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {

    return null;
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
