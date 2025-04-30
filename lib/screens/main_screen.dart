import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? currentUserEmail;
  String? deviceName;
  String? temperature;
  String? coffeeType;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email');
    final usersJson = prefs.getString('users');

    setState(() {
      currentUserEmail = email;
    });

    if (email != null && usersJson != null) {
      final decoded = jsonDecode(usersJson);
      if (decoded is Map<String, dynamic>) {
        final user = decoded[email];
        if (user != null && user is Map<String, dynamic>) {
          final settings = user['settings'] ?? <String,dynamic > {};
          setState(() {
            deviceName = settings['deviceName']?.toString() ?? 'Моя кавоварка';
            temperature = settings['temperature']?.toString() ?? 'Не вказано';
            coffeeType = settings['coffeeType']?.toString() ?? 'Не вказано';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Головна сторінка (${currentUserEmail ?? "гість"})'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade500, Colors.purple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentUserEmail != null
                    ? 'Вітаємо, $currentUserEmail!'
                    : 'Ласкаво просимо до розумної кавоварки!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Назва: ${deviceName ?? "-"}\nТемпература: ${temperature ??
                    "-"}\nТип кави: ${coffeeType ?? "-"}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  debugPrint('Кавоварка включена');
                },
                icon: const Icon(Icons.coffee, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 144, 115, 194),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 28,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                label: const Text(
                  'Запустити кавоварку',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
                icon: const Icon(Icons.settings, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 163, 139, 204),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 28,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                label: const Text(
                  'Налаштування',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
