import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_project/data/mqtt_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:my_project/utils/network_helper.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String? currentUserEmail;
  String deviceName = 'Моя кавоварка';
  String coffeeType = 'Не вказано';
  double temperature = 0.0;

  late MQTTService mqttService;
  bool hasInternet = true;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
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

  Future<void> loadCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('current_user_email');
    final usersJson = prefs.getString('users');

    setState(() {
      currentUserEmail = email;
    });

    if (email != null && usersJson != null) {
      try {
        final decoded = jsonDecode(usersJson);
        if (decoded is Map) {
          final user = decoded[email];
          if (user is Map) {
            final settings = user['settings'];
            if (settings is Map) {
              setState(() {
                deviceName = settings['deviceName']?.toString() ?? 'Моя кавоварка';
                coffeeType = settings['coffeeType']?.toString() ?? 'Не вказано';
              });
            }
          }
        }
      } catch (e) {
        debugPrint('JSON decode error: $e');
      }
    }
  }

  void monitorNetworkStatus() async {
    // Початкова перевірка
    final initialStatus = await NetworkHelper.hasInternetConnection();
    setState(() => hasInternet = initialStatus);

    Connectivity().onConnectivityChanged.listen((_) async {
      final internet = await NetworkHelper.hasInternetConnection();
      if (!mounted) return;
      setState(() => hasInternet = internet);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(internet ? 'Інтернет зʼєднання відновлено' : 'Немає Інтернету'),
          backgroundColor: internet ? Colors.green : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade500, Colors.purple.shade900],
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
                  'Назва: $deviceName\nТемпература: ${temperature.toStringAsFixed(1)} °C\nТип кави: $coffeeType',
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
                      const SnackBar(content: Text('Кавоварка увімкнена')),
                    );
                  },
                  icon: const Icon(Icons.coffee, color: Colors.white),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 144, 115, 194),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
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
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
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
      ),
    );
  }
}
