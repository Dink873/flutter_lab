import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  late final MqttServerClient _client;

  Function(String)? onTemperatureReceived;

  MQTTService() {
    final uniqueClientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient('test.mosquitto.org', uniqueClientId);
  }

  Future<void> connect() async {
    _client.port = 1883;
    _client.keepAlivePeriod = 20;
    _client.logging(on: false);
    _client.onDisconnected = () => print('MQTT disconnected');

    try {
      final connMess = MqttConnectMessage()
          .withClientIdentifier(_client.clientIdentifier!)
          .withWillTopic('willtopic')
          .withWillMessage('Client disconnected unexpectedly')
          .startClean()
          .withWillQos(MqttQos.atMostOnce);

      _client.connectionMessage = connMess;

      print('Connecting to MQTT broker...');
      await _client.connect();

      if (_client.connectionStatus?.state == MqttConnectionState.connected) {
        print('MQTT connected');
        _client.subscribe('sensor/temperature', MqttQos.atMostOnce);

        _client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>> c) {
          final recMess = c[0].payload as MqttPublishMessage;
          final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
          print('Received temperature: $pt');
          if (onTemperatureReceived != null) {
            onTemperatureReceived!(pt);
          }
        });
      } else {
        print('Connection failed: ${_client.connectionStatus}');
        _client.disconnect();
      }
    } catch (e) {
      print('MQTT connection failed: $e');
      _client.disconnect();
    }
  }
}
