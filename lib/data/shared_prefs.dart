import 'dart:convert';
import 'package:my_project/data/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String usersKey = 'users';
const String currentUserEmailKey = 'current_user_email';

class SharedPrefsStorage implements LocalStorage {
  @override
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(usersKey);

    List<Map<String, dynamic>> users = [];

    if (usersJson != null) {
      final decoded = jsonDecode(usersJson);
      if (decoded is List) {
        users = decoded
            .whereType<Map<String, dynamic>>()
            .map(Map<String, dynamic>.from)
            .toList();
      }
    }

    final int existingIndex =
    users.indexWhere((u) => u['email'] == user['email']);
    if (existingIndex != -1) {
      users[existingIndex] = user;
    } else {
      users.add(user);
    }

    await prefs.setString(usersKey, jsonEncode(users));
    await prefs.setString(currentUserEmailKey, user['email'] as String);
    await prefs.setBool('isLoggedIn', true);
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(usersKey);

    if (usersJson == null) return [];

    final decoded = jsonDecode(usersJson);
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
    }

    return [];
  }

  @override
  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(usersKey);
    final String? currentEmail = prefs.getString(currentUserEmailKey);

    if (usersJson == null || currentEmail == null) return null;

    final decoded = jsonDecode(usersJson);
    if (decoded is List) {
      final users = decoded
          .whereType<Map<String, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
      final user = users.firstWhere(
            (u) => u['email'] == currentEmail,
        orElse: () => {},
      );
      if (user.isNotEmpty) return user;
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(currentUserEmailKey);
    await prefs.setBool('isLoggedIn', false);
  }

  @override
  Future<void> updateUserSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString(usersKey);
    final String? currentEmail = prefs.getString(currentUserEmailKey);

    if (usersJson == null || currentEmail == null) return;

    final decoded = jsonDecode(usersJson);
    if (decoded is List) {
      final users = decoded
          .whereType<Map<String, dynamic>>()
          .map(Map<String, dynamic>.from)
          .toList();
      final int index = users.indexWhere((u) => u['email'] == currentEmail);
      if (index != -1) {
        users[index]['settings'] = Map<String, dynamic>.from(settings);
        await prefs.setString(usersKey, jsonEncode(users));
      }
    }
  }
}
