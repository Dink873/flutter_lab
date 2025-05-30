import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubit/user_cubit.dart';
import 'package:my_project/scanner/qr_scanner_screen.dart';
import 'package:my_project/screens/dialogs.dart';
import 'package:my_project/screens/profile_helpers.dart';
import 'package:my_project/usb/usb_manager.dart';
import 'package:my_project/usb/usb_service.dart';

Stream<String> mqttStream() async* {
  final receivePort = ReceivePort();
  await Isolate.spawn(
        (SendPort sendPort) async {
      for (int i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(seconds: 2));
        sendPort.send('ізолятор Температура = ${20 + i}°C');
      }
    },
    receivePort.sendPort,
  );
  await for (var data in receivePort) {
    if (data is String) yield data;
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, state) {
        if (state is UserLoading) return loadingScreen();
        if (state is UserLoaded) {
          return StreamBuilder<String>(
            stream: mqttStream(),
            initialData: 'Очікування повідомлень з MQTT...',
            builder: (context, snapshot) {
              return buildProfile(
                context,
                state.user.email,
                state.user.name,
                snapshot.data ?? '',
                // scanQrAndSend
                    () {
                  Navigator.of(context)
                      .push<String>(
                    MaterialPageRoute(
                      builder: (_) => QRScannerScreen(),
                    ),
                  )
                      .then((scannedText) async {
                    if (scannedText == null) return;
                    final usbManager = UsbManager(UsbService());
                    final port = await usbManager.selectDevice();
                    if (port == null) {
                      if(context.mounted) {
                        showSnack(context, '❌ Arduino не знайдено');
                      }
                      return;
                    }
                    try {

                      await usbManager.sendData('$scannedText\n');
                      if(context.mounted) {
                        showSnack(
                          context,
                          '✅ QR надіслано: $scannedText',
                        );
                      }
                    } catch (e) {
                      if(context.mounted) {
                        showErrorDialog(
                          context,
                          'Не вдалося відправити QR-код: $e',
                        );
                      }
                    }
                  });
                },
                // logout
                    () {
                  showLogoutDialog(context).then((shouldLogout) async {
                    if (shouldLogout == true) {
                      if (context.mounted) {
                        await context.read<UserCubit>().logout();
                        if (context.mounted) {
                          Navigator.of(context)
                              .pushReplacementNamed('/login');
                        }
                      }
                    }
                  });
                },
              );
            },
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
          body: Center(child: Text('Невідомий стан')),
        );
      },
    );
  }
}
