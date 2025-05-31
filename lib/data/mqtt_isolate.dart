import 'dart:isolate';

void mqttWorker(SendPort sendPort) async {
  for (int i = 0; i < 5; i++) {
    await Future<void>.delayed(const Duration(seconds: 2));
    sendPort.send('MQTT: Температура = ${20 + i}°C');
  }
}
