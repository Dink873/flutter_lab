import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubit/user_cubit.dart';
import 'package:my_project/scanner/qr_scanner_screen.dart';
import 'package:my_project/screens/dialogs.dart';
import 'package:my_project/screens/profile_helpers.dart';
import 'package:my_project/usb/usb_manager.dart';
import 'package:my_project/usb/usb_service.dart';

Future<void> mqttWorker(SendPort sendPort) async {
  for (int i = 0; i < 100; i++) {
    await Future<void>.delayed(const Duration(seconds: 2));
    sendPort.send('ізолятор Температура = ${20 + i}°C');
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String mqttMessage = 'Очікування повідомлень з MQTT...';
  Isolate? _mqttIsolate;
  ReceivePort? _receivePort;
  final usbManager = UsbManager(UsbService());

  @override
  void initState() {
    super.initState();
    startMqttIsolate();
    context.read<UserCubit>().checkLoginStatus();
  }

  void startMqttIsolate() async {
    _receivePort = ReceivePort();
    _mqttIsolate = await Isolate.spawn(
      mqttWorker,
      _receivePort!.sendPort,
    );
    _receivePort!.listen((data) {
      if (mounted) setState(() => mqttMessage = data.toString());
    });
  }

  @override
  void dispose() {
    _mqttIsolate?.kill(priority: Isolate.immediate);
    _receivePort?.close();
    usbManager.dispose();
    super.dispose();
  }

  Future<void> logout() async {
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout == true && mounted) {
      await context.read<UserCubit>().logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  Future<void> scanQrAndSend() async {
    final scannedText = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => QRScannerScreen(),
      ),
    );
    if (!mounted || scannedText == null) return;
    final port = await usbManager.selectDevice();
    if (!mounted) return;
    if (port == null) {
      showSnack(context, '❌ Arduino не знайдено');
      return;
    }
    try {
      await usbManager.sendData('$scannedText\n');
      if (mounted) {
        showSnack(context, '✅ QR надіслано: $scannedText');
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(
          context,
          'Не вдалося відправити QR-код: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) return loadingScreen();
        if (state is UserLoaded) {
          return buildProfile(
            context,
            state.user.email,
            state.user.name,
            mqttMessage,
            scanQrAndSend,
            logout,
          );
        }
        if (state is UserUnauthenticated) {
          WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.of(context).pushReplacementNamed('/login'),
          );
          return const SizedBox();
        }
        if (state is UserError) return errorScreen(state.message);
        return const Scaffold(
          body: Center(
            child: Text('Невідомий стан'),
          ),
        );
      },
    );
  }
}
