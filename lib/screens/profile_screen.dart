import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? currentUser;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email');
    final usersJson = prefs.getString('users');

    if (usersJson != null && email != null) {
      final decoded = jsonDecode(usersJson);

      if (decoded is Map<String, dynamic>) {
        final user = decoded[email];
        if (user != null && user is Map<String, dynamic>) {
          setState(() {
            currentUser = Map<String, dynamic>.from(user);
            currentUser!['email'] = email;
          });
        }
      }
    }
  }

  Future<void> logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Підтвердження'),
        content: const Text('Ви дійсно хочете вийти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Ні'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Так'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('current_user_email');
      await prefs.setBool('isLoggedIn', false);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final email = currentUser!['email'] as String? ?? 'Email не доступний';
    final name = currentUser!['name'] as String? ?? 'Ім’я не вказано';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профіль'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage('https://www.example.com/profile.jpg'),
              ),
              const SizedBox(height: 24),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                style: const TextStyle(fontSize: 18, color: Colors.white70),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  // Тут може бути логіка редагування профілю
                },
                icon: const Icon(Icons.edit, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 28,),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),),
                ),
                label: const Text('Редагувати профіль', style: TextStyle(
                    fontSize: 18,),),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 28,),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),),
                ),
                label: const Text('Вийти', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
