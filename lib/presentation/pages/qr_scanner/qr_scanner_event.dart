part of 'qr_scanner_bloc.dart';

abstract class QrScannerEvent extends Equatable {
  const QrScannerEvent();

  @override
  List<Object?> get props => [];
}

class QrCodeScanned extends QrScannerEvent {
  const QrCodeScanned(this.code);
  final String code;

  @override
  List<Object?> get props => [code];
}
