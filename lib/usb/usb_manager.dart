import 'package:my_project/usb/usb_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:usb_serial/usb_serial.dart';

class UsbManager {
  UsbManager(this.service) {
    refreshDeviceList();
  }

  final BaseUsbService service;
  final _cachedDevice = BehaviorSubject<List<UsbDevice>>.seeded([]);
  final _cachedPort = BehaviorSubject<UsbPort?>();
  final _cachedRate = BehaviorSubject<int>.seeded(115200);

  Stream<List<UsbDevice>> get device => _cachedDevice.stream;
  UsbPort? get port => _cachedPort.valueOrNull;

  Future<void> refreshDeviceList() async {
    final devices = await service.getDeviceList();
    _cachedDevice.add(devices);
  }

  Future<UsbPort?> selectDevice() async {
    var devices = _cachedDevice.value;
    if (devices.isEmpty) {
      await refreshDeviceList();
      devices = _cachedDevice.value;
    }

    if (devices.isEmpty) {
      return null;
    }

    await _cachedPort.valueOrNull?.close();

    final port = await service.connectToDevice(
      devices.first,
      rate: _cachedRate.value,
    );

    _cachedPort.add(port);
    return port;
  }

  Future<void> sendData(String data) async {
    final port = _cachedPort.valueOrNull;
    if (port != null) {
      await service.sendData(port, data: data);
    } else {
    }
  }

  Future<void> dispose() async {
    await _cachedPort.valueOrNull?.close();
    await _cachedDevice.close();
    await _cachedPort.close();
    await _cachedRate.close();
  }
}
