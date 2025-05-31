import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/usb/usb_manager.dart';
import 'package:my_project/usb/usb_service.dart';
import 'package:usb_serial/usb_serial.dart';

abstract class QrMessageState {}

class QrInitial extends QrMessageState {}

class QrLoading extends QrMessageState {}

class QrLoaded extends QrMessageState {
  final String message;
  QrLoaded(this.message);
}

class QrError extends QrMessageState {
  final String error;
  QrError(this.error);
}

class QrMessageCubit extends Cubit<QrMessageState> {
  QrMessageCubit() : super(QrInitial());

  Future<void> readMessage() async {
    emit(QrLoading());
    final usbManager = UsbManager(UsbService());
    try {
      final port = await usbManager.selectDevice();
      if (port == null) {
        await usbManager.dispose();
        emit(QrError('❌ Arduino не знайдено'));
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final response = await _readFromArduino(port);
      await usbManager.dispose();
      emit(QrLoaded(response));
    } catch (e) {
      emit(QrError('❌ ${e.toString()}'));
    }
  }

  static Future<String> _readFromArduino(UsbPort port) async {
    String buffer = '';
    final completer = Completer<String>();
    StreamSubscription<Uint8List>? sub;
    sub = port.inputStream?.listen(
          (data) {
        buffer += String.fromCharCodes(data);
        if (buffer.contains('\n')) {
          sub?.cancel();
          completer.complete(buffer.trim());
        }
      },
      onError: (Object error) {
        sub?.cancel();
        completer.completeError('❌ Помилка читання: $error');
      },
      cancelOnError: true,
    );

    return completer.future.timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        sub?.cancel();
        return '⏱ Немає відповіді від Arduino';
      },
    );
  }
}

class SavedQrScreen extends StatelessWidget {
  const SavedQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<QrMessageCubit>(
      create: (_) => QrMessageCubit()..readMessage(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Збережене повідомлення')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<QrMessageCubit, QrMessageState>(
              builder: (context, state) {
                if (state is QrLoading) {
                  return const Text(
                    'Зчитування...',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  );
                }
                if (state is QrLoaded) {
                  return Text(
                    state.message,
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  );
                }
                if (state is QrError) {
                  return Text(
                    state.error,
                    style: const TextStyle(fontSize: 20, color: Colors.red),
                    textAlign: TextAlign.center,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
