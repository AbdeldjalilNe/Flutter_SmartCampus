import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_theme.dart';
import 'qr_scanner_bloc.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _isFlashOn = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('QR Scanner'),
          actions: [
            IconButton(
              icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
              onPressed: () async {
                await controller.toggleTorch();
                setState(() {
                  _isFlashOn = !_isFlashOn;
                });
              },
            ),
          ],
        ),
        body: BlocConsumer<QrScannerBloc, QrScannerState>(
          listener: (context, state) {
            if (state is QrScannerSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Check-in successful: ${state.message}'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
              Navigator.pop(context);
            } else if (state is QrScannerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            }
          },
          builder: (context, state) => Column(
            children: [
              Expanded(
                flex: 5,
                child: MobileScanner(
                  controller: controller,
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (barcode.rawValue != null) {
                        context.read<QrScannerBloc>().add(QrCodeScanned(barcode.rawValue!));
                        break;
                      }
                    }
                  },
                ),
              ),
              const Expanded(
                child: ColoredBox(
                  color: Colors.black,
                  child: Center(
                    child: Text(
                      'Scan a QR code to check in',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
