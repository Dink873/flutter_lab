import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubit/user_cubit.dart';

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
    context.read<UserCubit>().register(email, password);
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
        child: BlocConsumer<UserCubit, UserState>(
          listener: (context, state) {
            if (state is UserLoaded) {
              Navigator.pushReplacementNamed(context, '/main');
            } else if (state is UserError) {
              setState(() {
                _errorMessage = state.message;
              });
            }
          },
          builder: (context, state) {
            return Form(
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
                    Text(_errorMessage!, style: const TextStyle
                      (color: Colors.red),),
                  const SizedBox(height: 20),
                  if (state is UserLoading)
                    const CircularProgressIndicator(),
                  ElevatedButton(
                    onPressed: (state is UserLoading) ? null : _register,
                    child: const Text('Зареєструватися'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
