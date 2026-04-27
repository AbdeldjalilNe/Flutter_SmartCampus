import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class QrScannerEvent {}
class QrScannerStarted extends QrScannerEvent {}
class QrCodeScanned extends QrScannerEvent {
  QrCodeScanned(this.qrData);
  final String qrData;
}

// States
abstract class QrScannerState {}
class QrScannerInitial extends QrScannerState {}
class QrScannerScanning extends QrScannerState {}
class QrScannerSuccess extends QrScannerState {
  QrScannerSuccess(this.qrData);
  final String qrData;
}
class QrScannerError extends QrScannerState {
  QrScannerError(this.message);
  final String message;
}

// BLoC
class QrScannerBloc extends Bloc<QrScannerEvent, QrScannerState> {
  QrScannerBloc() : super(QrScannerInitial()) {
    on<QrScannerStarted>((event, emit) {
      emit(QrScannerScanning());
    });
    on<QrCodeScanned>((event, emit) {
      emit(QrScannerSuccess(event.qrData));
    });
  }
}
