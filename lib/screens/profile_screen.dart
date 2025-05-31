import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/cubit/mqtt_cubit.dart';
import 'package:my_project/cubit/usb_cubit.dart';
import 'package:my_project/cubit/user_cubit.dart';
import 'package:my_project/scanner/qr_scanner_screen.dart';
import 'package:my_project/screens/dialogs.dart';
import 'package:my_project/screens/profile_helpers.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MqttCubit>(
          create: (_) => MqttCubit(),
        ),
        BlocProvider<UsbCubit>(
          create: (_) => UsbCubit(),
        ),
      ],
      child: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading) return loadingScreen();
          if (state is UserLoaded) {
            return BlocBuilder<MqttCubit, MqttState>(
              builder: (context, mqttState) {
                return BlocConsumer<UsbCubit, UsbState>(
                  listener: (context, usbState) {
                    if (usbState is UsbSuccess) {
                      showSnack(context, usbState.message);
                    } else if (usbState is UsbError) {
                      showErrorDialog(context, usbState.error);
                    }
                  },
                  builder: (context, usbState) {
                    return buildProfile(
                      context,
                      state.user.email,
                      state.user.name,
                      mqttState.message,
                          () async {
                        final scannedText =
                        await Navigator.of(context).push<String>(
                          MaterialPageRoute(
                            builder: (_) => QRScannerScreen(),
                          ),
                        );
                        if (!context.mounted) return;
                        if (scannedText != null) {
                          context.read<UsbCubit>().sendQr(scannedText);
                        }
                      },
                          () {
                        showLogoutDialog(context).then((shouldLogout) async {
                          if (shouldLogout == true && context.mounted) {
                            await context.read<UserCubit>().logout();
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            }
                          }
                        });
                      },
                    );
                  },
                );
              },
            );
          }
          if (state is UserUnauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback(
                  (_) {
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
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
      ),
    );
  }
}
