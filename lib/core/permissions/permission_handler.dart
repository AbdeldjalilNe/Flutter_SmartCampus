import 'package:geolocator/geolocator.dart';
import 'package:local_auth/local_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import '../errors/exceptions.dart' hide PermissionDeniedException;
import '../utils/logger.dart';

class PermissionHandlerService {
  // Location Permissions
  Future<bool> requestLocationPermission() async {
    try {
      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw const PermissionDeniedException(
            'Location permission denied',
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw const PermissionDeniedException(
              'Location permission permanently denied. Please enable in settings.',
        );
      }

      AppLogger.info('Location permission granted');
      return true;
    } catch (e) {
      AppLogger.error('Error requesting location permission', e);
      rethrow;
    }
  }

  Future<bool> isLocationPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<bool> isLocationServiceEnabled() async =>
      Geolocator.isLocationServiceEnabled();

  // Camera Permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();

    if (status.isDenied) {
      throw const PermissionDeniedException(
        'Camera permission denied',
      );
    }

    if (status.isPermanentlyDenied) {
      throw const PermissionDeniedException(
            'Camera permission permanently denied. Please enable in settings.',
      );
    }

    AppLogger.info('Camera permission granted');
    return status.isGranted;
  }

  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  // Gallery/Photos Permission
  Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();

    if (status.isDenied) {
      throw const PermissionDeniedException(
        'Photos permission denied',
      );
    }

    if (status.isPermanentlyDenied) {
      throw const PermissionDeniedException(
            'Photos permission permanently denied. Please enable in settings.',
      );
    }

    AppLogger.info('Photos permission granted');
    return status.isGranted;
  }

  Future<bool> isPhotosPermissionGranted() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }

  // Storage Permission
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();

    if (status.isDenied) {
      throw const PermissionDeniedException(
        'Storage permission denied',
      );
    }

    if (status.isPermanentlyDenied) {
      throw const PermissionDeniedException(
            'Storage permission permanently denied. Please enable in settings.',
      );
    }

    AppLogger.info('Storage permission granted');
    return status.isGranted;
  }

  // Notification Permission
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();

    if (status.isDenied) {
      throw const PermissionDeniedException(
        'Notification permission denied',
      );
    }

    AppLogger.info('Notification permission granted');
    return status.isGranted;
  }

  Future<bool> isNotificationPermissionGranted() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // Biometric Permission
  Future<bool> requestBiometricPermission() async {
    final localAuth = LocalAuthentication();

    final canCheckBiometrics = await localAuth.canCheckBiometrics;
    if (!canCheckBiometrics) {
      throw const BiometricException(
        message: 'Biometric authentication not available on this device',
        type: BiometricErrorType.notAvailable,
      );
    }

    final availableBiometrics =
        await localAuth.getAvailableBiometrics();

    if (availableBiometrics.isEmpty) {
      throw const BiometricException(
        message: 'No biometric methods enrolled on this device',
        type: BiometricErrorType.notEnrolled,
      );
    }

    AppLogger.info(
        'Biometric permission granted. Available: $availableBiometrics',);
    return true;
  }

  Future<bool> isBiometricAvailable() async {
    final localAuth = LocalAuthentication();
    final canCheckBiometrics = await localAuth.canCheckBiometrics;
    final availableBiometrics =
        await localAuth.getAvailableBiometrics();
    return canCheckBiometrics && availableBiometrics.isNotEmpty;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    final localAuth = LocalAuthentication();
    return localAuth.getAvailableBiometrics();
  }

  // Microphone Permission
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();

    if (status.isDenied) {
      throw const PermissionDeniedException(
        'Microphone permission denied',
      );
    }

    if (status.isPermanentlyDenied) {
      throw const PermissionDeniedException(
            'Microphone permission permanently denied. Please enable in settings.',
      );
    }

    AppLogger.info('Microphone permission granted');
    return status.isGranted;
  }

  // Bluetooth Permission
  Future<bool> requestBluetoothPermission() async {
    final status = await Permission.bluetooth.request();

    if (status.isDenied) {
      throw const PermissionDeniedException(
        'Bluetooth permission denied',
      );
    }

    AppLogger.info('Bluetooth permission granted');
    return status.isGranted;
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // Check multiple permissions at once
  Future<Map<Permission, PermissionStatus>> checkMultiplePermissions(
    List<Permission> permissions,
  ) async =>
      permissions.request();

  // Request all essential permissions
  Future<Map<String, bool>> requestEssentialPermissions() async {
    final results = <String, bool>{};

    try {
      results['location'] = await requestLocationPermission();
    } catch (e) {
      results['location'] = false;
    }

    try {
      results['camera'] = await requestCameraPermission();
    } catch (e) {
      results['camera'] = false;
    }

    try {
      results['photos'] = await requestPhotosPermission();
    } catch (e) {
      results['photos'] = false;
    }

    try {
      results['notifications'] = await requestNotificationPermission();
    } catch (e) {
      results['notifications'] = false;
    }

    AppLogger.info('Essential permissions requested: $results');
    return results;
  }
}

// Permission status helper
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted,
  limited,
  unknown,
}

extension PermissionStatusExtension on PermissionStatus {
  AppPermissionStatus toAppStatus() {
    switch (this) {
      case PermissionStatus.granted:
        return AppPermissionStatus.granted;
      case PermissionStatus.denied:
        return AppPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return AppPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return AppPermissionStatus.restricted;
      case PermissionStatus.limited:
        return AppPermissionStatus.limited;
      default:
        return AppPermissionStatus.unknown;
    }
  }
}
