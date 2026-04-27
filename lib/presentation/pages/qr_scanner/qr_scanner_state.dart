part of 'qr_scanner_bloc.dart';

abstract class QrScannerState extends Equatable {
  const QrScannerState();

  @override
  List<Object?> get props => [];
}

class QrScannerInitial extends QrScannerState {}

class QrScannerLoading extends QrScannerState {}

class QrScannerSuccess extends QrScannerState {
  const QrScannerSuccess({
    required this.eventId,
    required this.message,
  });
  final String eventId;
  final String message;

  @override
  List<Object?> get props => [eventId, message];
}

class QrScannerError extends QrScannerState {
  const QrScannerError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
