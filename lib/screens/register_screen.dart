import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    final usersRaw = prefs.getString('users');


    Map<String, dynamic> users = {};

    if (usersRaw != null) {
      final dynamic decoded = jsonDecode(usersRaw);
      if (decoded is Map<String, dynamic>) {
        users = Map<String, dynamic>.from(decoded);
      }
    }

    if (users.containsKey(email)) {
      setState(() => _errorMessage = 'Користувач з таким email вже існує');
      return;
    }

    users[email] = {'password': password};

    await prefs.setString('users', jsonEncode(users));
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('current_user_email', email);

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/main');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Реєстрація')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) =>
                EmailValidator.validate(value ?? '') ?
                null : 'Некоректний email',
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль'),
                validator: (value) =>
                (value != null && value.length >= 6) ?
                null : 'Мінімум 6 символів',
              ),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Підтвердіть пароль',),
                validator: (value) =>
                value == _passwordController.text ?
                null : 'Паролі не співпадають',
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: const Text('Зареєструватися'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
