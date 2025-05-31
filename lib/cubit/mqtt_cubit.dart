import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class MqttState {
  final String message;
  MqttState(this.message);
}

class MqttCubit extends Cubit<MqttState> {
  StreamSubscription<String>? _subscription;

  MqttCubit() : super(MqttState('Очікування повідомлень з MQTT...')) {
    _startMockStream();
  }

  void _startMockStream() {
    Stream<String> mqttStream() async* {
      for (int i = 0; i < 100; i++) {
        await Future<void>.delayed(const Duration(seconds: 2));
        yield 'ізолятор Температура = ${20 + i}°C';
      }
    }

    _subscription = mqttStream().listen((msg) {
      emit(MqttState(msg));
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
