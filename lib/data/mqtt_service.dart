import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late final MqttServerClient _client;

  void Function(String)? onTemperatureReceived;

  MQTTService() {
    final uniqueClientId = 'flutter_client_${
        DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient('test.mosquitto.org', uniqueClientId);
  }

  Future<void> connect() async {
    _client.port = 1883;
    _client.keepAlivePeriod = 20;
    _client.logging(on: false);
    _client.onDisconnected = () => debugPrint('MQTT disconnected');

    final connMess = MqttConnectMessage()
        .withClientIdentifier(_client.clientIdentifier)
        .withWillTopic('willtopic')
        .withWillMessage('Client disconnected unexpectedly')
        .startClean()
        .withWillQos(MqttQos.atMostOnce);

    _client.connectionMessage = connMess;

    try {
      debugPrint('Connecting to MQTT broker...');
      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        debugPrint('MQTT connected');
        _client.subscribe('sensor/temperature', MqttQos.atMostOnce);

        _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
          final message = c[0].payload as MqttPublishMessage;
          final payload = MqttPublishPayload.bytesToStringAsString(
              message.payload.message,);
          debugPrint('Received temperature: $payload');

          onTemperatureReceived?.call(payload);
        });
      } else {
        debugPrint('Connection failed: ${_client.connectionStatus}');
        _client.disconnect();
      }
    } catch (e) {
      debugPrint('MQTT connection failed: $e');
      _client.disconnect();
    }
  }
}
