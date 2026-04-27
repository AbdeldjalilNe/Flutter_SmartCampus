import 'package:equatable/equatable.dart';

class CheckIn extends Equatable {
  const CheckIn({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.checkInTime,
    this.qrCodeData,
    this.latitude,
    this.longitude,
    this.isValid = true,
    this.validationMessage,
    this.createdAt,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) => CheckIn(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      qrCodeData: json['qrCodeData'] as String?,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      isValid: json['isValid'] as bool? ?? true,
      validationMessage: json['validationMessage'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  final String id;
  final String eventId;
  final String userId;
  final DateTime checkInTime;
  final String? qrCodeData;
  final double? latitude;
  final double? longitude;
  final bool isValid;
  final String? validationMessage;
  final DateTime? createdAt;

  bool get hasLocation => latitude != null && longitude != null;

  CheckIn copyWith({
    String? id,
    String? eventId,
    String? userId,
    DateTime? checkInTime,
    String? qrCodeData,
    double? latitude,
    double? longitude,
    bool? isValid,
    String? validationMessage,
    DateTime? createdAt,
  }) =>
      CheckIn(
        id: id ?? this.id,
        eventId: eventId ?? this.eventId,
        userId: userId ?? this.userId,
        checkInTime: checkInTime ?? this.checkInTime,
        qrCodeData: qrCodeData ?? this.qrCodeData,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        isValid: isValid ?? this.isValid,
        validationMessage: validationMessage ?? this.validationMessage,
        createdAt: createdAt ?? this.createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'userId': userId,
        'checkInTime': checkInTime.toIso8601String(),
        'qrCodeData': qrCodeData,
        'latitude': latitude,
        'longitude': longitude,
        'isValid': isValid,
        'validationMessage': validationMessage,
        'createdAt': createdAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        eventId,
        userId,
        checkInTime,
        qrCodeData,
        latitude,
        longitude,
        isValid,
        validationMessage,
        createdAt,
      ];
}

// QR Code validation result
class QrValidationResult {
  const QrValidationResult({
    required this.isValid,
    this.eventId,
    this.message,
    this.checkIn,
  });

  factory QrValidationResult.valid(String eventId, CheckIn checkIn) => QrValidationResult(
      isValid: true,
      eventId: eventId,
      checkIn: checkIn,
    );

  factory QrValidationResult.invalid(String message) => QrValidationResult(
      isValid: false,
      message: message,
    );
  final bool isValid;
  final String? eventId;
  final String? message;
  final CheckIn? checkIn;
}
