import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:my_project/cubit/user_cubit.dart';
import 'package:my_project/data/mqtt_service.dart';
import 'package:my_project/utils/network_helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String deviceName = 'Моя кавоварка';
  String coffeeType = 'Не вказано';
  double temperature = 0;
  bool hasInternet = true;

  late MQTTService mqttService;

  @override
  void initState() {
    super.initState();
    initMQTT();
    monitorNetworkStatus();
  }

  void initMQTT() {
    mqttService = MQTTService();
    mqttService.onTemperatureReceived = (String value) {
      setState(() {
        temperature = double.tryParse(value) ?? 0.0;
      });
    };
    mqttService.connect();
  }

  void monitorNetworkStatus() async {
    final initialStatus = await NetworkHelper.hasInternetConnection();
    setState(() => hasInternet = initialStatus);

    Connectivity().onConnectivityChanged.listen((_) async {
      final internet = await NetworkHelper.hasInternetConnection();
      if (!mounted) return;
      setState(() => hasInternet = internet);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            internet
                ? 'Інтернет зʼєднання відновлено'
                : 'Немає Інтернету',
          ),
          backgroundColor: internet ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        String? currentUserEmail;
        // Витягуємо deviceName та coffeeType з User.settings, якщо вони є
        if (state is UserLoaded) {
          currentUserEmail = state.user.email;
          final settings = state.user.settings;
          if (settings != null) {
            deviceName = settings['deviceName']?.toString() ?? deviceName;
            coffeeType = settings['coffeeType']?.toString() ?? coffeeType;
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Головна (${currentUserEmail ?? "гість"})'),
            backgroundColor: Colors.deepPurple,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(
                      hasInternet ? Icons.wifi : Icons.wifi_off,
                      color: hasInternet ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      hasInternet ? 'Online' : 'Offline',
                      style: TextStyle(
                        color: hasInternet ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
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
                            content: Text('Кавоварка увімкнена'),
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
