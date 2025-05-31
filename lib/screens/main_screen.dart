import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubit/user_cubit.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String deviceName = 'Моя кавоварка';
        String coffeeType = 'Не вказано';
        double temperature = 0;
        String? currentUserEmail;

        if (state is UserLoaded) {
          currentUserEmail = state.user.email;
          final settings = state.user.settings;
          if (settings != null) {
            deviceName = settings['deviceName']?.toString() ?? deviceName;
            coffeeType = settings['coffeeType']?.toString() ?? coffeeType;
            temperature = double.tryParse(
              settings['temperature']?.toString() ?? '0',
            ) ??
                0.0;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Головна (${currentUserEmail ?? "гість"})',
            ),
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
                colors: [
                  Colors.indigo.shade500,
                  Colors.purple.shade900,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
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
                      'Назва: $deviceName\n'
                          'Температура: ${temperature.toStringAsFixed(1)} °C\n'
                          'Тип кави: $coffeeType',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Кавоварка увімкнена',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.coffee, color: Colors.white),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color.fromARGB(255, 144, 115, 194),
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
                        backgroundColor:
                        const Color.fromARGB(255, 163, 139, 204),
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
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
