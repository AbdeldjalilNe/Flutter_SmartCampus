part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  const Authenticated({
    required this.user,
    this.isBiometric = false,
  });
  final User user;
  final bool isBiometric;

  @override
  List<Object?> get props => [user, isBiometric];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  const AuthError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}

class PasswordChangedSuccess extends AuthState {
  const PasswordChangedSuccess();
}

class PasswordResetEmailSent extends AuthState {
  const PasswordResetEmailSent();
}

class BiometricToggled extends AuthState {
  const BiometricToggled({required this.enabled});
  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}
