import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_project/usb/usb_manager.dart';
import 'package:my_project/usb/usb_service.dart';

abstract class UsbState {}
class UsbInitial extends UsbState {}
class UsbLoading extends UsbState {}
class UsbSuccess extends UsbState {
  final String message;
  UsbSuccess(this.message);
}
class UsbError extends UsbState {
  final String error;
  UsbError(this.error);
}

class UsbCubit extends Cubit<UsbState> {
  UsbCubit() : super(UsbInitial());

  Future<void> sendQr(String scannedText) async {
    emit(UsbLoading());
    final usbManager = UsbManager(UsbService());
    try {
      final port = await usbManager.selectDevice();
      if (port == null) {
        emit(UsbError('❌ Arduino не знайдено'));
        return;
      }
      await usbManager.sendData('$scannedText\n');
      emit(UsbSuccess('✅ QR надіслано: $scannedText'));
    } catch (e) {
      emit(UsbError('Не вдалося відправити QR-код: $e'));
    }
  }
}
