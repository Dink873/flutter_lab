import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _deviceController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _coffeeTypeController = TextEditingController();

  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email');
    final String? usersJson = prefs.getString('users');

    if (email != null && usersJson != null) {
      final dynamic decoded = jsonDecode(usersJson);

      if (decoded is List) {
        final List<Map<String, dynamic>> users = decoded
            .whereType<Map<String, dynamic>>()
            .toList();

        final user = users.firstWhere(
              (u) => u['email'] == email,
          orElse: () => <String, dynamic>{},
        );

        if (user.isNotEmpty) {
          final settings = user['settings'] as Map<String, dynamic>? ?? {};

          setState(() {
            currentUserEmail = email;
            _deviceController.text = settings['deviceName']
                ?.toString() ?? '';
            _temperatureController.text = settings['temperature']
                ?.toString() ?? '';
            _coffeeTypeController.text = settings['coffeeType']
                ?.toString() ?? '';
          });
        }
      }
    }
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? usersJson = prefs.getString('users');

    if (currentUserEmail == null || usersJson == null) return;

    final dynamic decoded = jsonDecode(usersJson);
    if (decoded is List) {
      final List<Map<String, dynamic>> users = decoded
          .whereType<Map<String, dynamic>>()
          .toList();

      final int index = users.indexWhere((u) => u['email'] == currentUserEmail);
      if (index != -1) {
        users[index]['settings'] = {
          'deviceName': _deviceController.text.trim(),
          'temperature': _temperatureController.text.trim(),
          'coffeeType': _coffeeTypeController.text.trim(),
        };

        await prefs.setString('users', jsonEncode(users));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Settings saved')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _deviceController.dispose();
    _temperatureController.dispose();
    _coffeeTypeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Maker Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _deviceController,
              decoration: const InputDecoration(
                labelText: 'Device Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _temperatureController,
              decoration: const InputDecoration(
                labelText: 'Temperature',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _coffeeTypeController,
              decoration: const InputDecoration(
                labelText: 'Coffee Type',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: saveSettings,
              icon: const Icon(Icons.save, color: Colors.white),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                    vertical: 14, horizontal: 28,),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              label: const Text(
                'Save Settings',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
