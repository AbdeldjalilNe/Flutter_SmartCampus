part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  const LoginRequested({
    required this.email,
    required this.password,
  });
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  const RegisterRequested({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.studentId,
  });
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? studentId;

  @override
  List<Object?> get props => [email, password, firstName, lastName, studentId];
}

class LogoutRequested extends AuthEvent {}

class BiometricLoginRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class UpdateProfileRequested extends AuthEvent {
  const UpdateProfileRequested({
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.department,
  });
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String? department;

  @override
  List<Object?> get props => [firstName, lastName, avatarUrl, department];
}

class ChangePasswordRequested extends AuthEvent {
  const ChangePasswordRequested({
    required this.currentPassword,
    required this.newPassword,
  });
  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class ResetPasswordRequested extends AuthEvent {
  const ResetPasswordRequested({required this.email});
  final String email;

  @override
  List<Object?> get props => [email];
}

class ToggleBiometric extends AuthEvent {
  const ToggleBiometric({required this.enabled});
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}
