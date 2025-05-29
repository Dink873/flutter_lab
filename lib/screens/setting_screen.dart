import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubit/user_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _deviceController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _coffeeTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<UserCubit>().state;
    if (state is UserLoaded) {
      final settings = state.user.settings ?? {};
      _deviceController.text = settings['deviceName']?.toString() ?? '';
      _temperatureController.text = settings['temperature']?.toString() ?? '';
      _coffeeTypeController.text = settings['coffeeType']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _deviceController.dispose();
    _temperatureController.dispose();
    _coffeeTypeController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final settings = {
      'deviceName': _deviceController.text.trim(),
      'temperature': _temperatureController.text.trim(),
      'coffeeType': _coffeeTypeController.text.trim(),
    };
    context.read<UserCubit>().saveSettings(settings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Налаштування збережено')),
    );
  }

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
          if (state is UserLoaded) {
          }
          return Padding(
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
                  onPressed: _saveSettings,
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
