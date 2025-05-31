import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  /// Перевіряє, чи є реальний інтернет (не просто WiFi/data, а саме доступ до зовнішнього ресурсу)
  static Future<bool> hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return false;

    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      // print('No internet connection: $e');
      return false;
    }
  }

  /// Stream, що реагує на зміну стану мережі (WiFi, mobile, none)
  static Stream<ConnectivityResult> get onConnectionChange =>
      Connectivity().onConnectivityChanged;
}
