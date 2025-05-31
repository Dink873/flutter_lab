import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubit/user_cubit.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coffee Maker Settings'),
        backgroundColor: Colors.deepPurple,
      ),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          Map<String, dynamic> settings = {};
          if (state is UserLoaded) {
            settings = state.user.settings ?? {};
          }

          final deviceController = TextEditingController(
              text: settings['deviceName']?.toString() ?? '',);
          final temperatureController = TextEditingController(
              text: settings['temperature']?.toString() ?? '',);
          final coffeeTypeController = TextEditingController(
              text: settings['coffeeType']?.toString() ?? '',);

          void saveSettings() {
            final updatedSettings = {
              'deviceName': deviceController.text.trim(),
              'temperature': temperatureController.text.trim(),
              'coffeeType': coffeeTypeController.text.trim(),
            };
            context.read<UserCubit>().saveSettings(updatedSettings);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Налаштування збережено')),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              children: [
                TextField(
                  controller: deviceController,
                  decoration: const InputDecoration(
                    labelText: 'Device Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: temperatureController,
                  decoration: const InputDecoration(
                    labelText: 'Temperature',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: coffeeTypeController,
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
                      vertical: 14, horizontal: 28,
                    ),
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
          );
        },
      ),
    );
  }
}
