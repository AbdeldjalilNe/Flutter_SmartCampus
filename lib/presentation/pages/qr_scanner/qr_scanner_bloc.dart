import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'qr_scanner_event.dart';
part 'qr_scanner_state.dart';

class QrScannerBloc extends Bloc<QrScannerEvent, QrScannerState> {
  QrScannerBloc() : super(QrScannerInitial()) {
    on<QrCodeScanned>(_onQrCodeScanned);
  }

  Future<void> _onQrCodeScanned(
    QrCodeScanned event,
    Emitter<QrScannerState> emit,
  ) async {
    emit(QrScannerLoading());

    try {
      // Parse QR code data
      // Expected format: "event://{eventId}?code={checkInCode}"

      if (event.code.startsWith('event://')) {
        final uri = Uri.parse(event.code);
        final eventId = uri.host;
        final checkInCode = uri.queryParameters['code'];

        if (eventId.isNotEmpty) {
          // Simulate API call for check-in
          await Future.delayed(const Duration(seconds: 1));

          emit(QrScannerSuccess(
            eventId: eventId,
            message: 'Successfully checked in to event',
          ),);
        } else {
          emit(const QrScannerError('Invalid QR code format'));
        }
      } else {
        emit(const QrScannerError('Invalid QR code'));
      }
    } catch (e) {
      emit(QrScannerError('Failed to process QR code: $e'));
    }
  }
}
