import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<UpdateProfileRequested>(_onUpdateProfileRequested);
    on<ChangePasswordRequested>(_onChangePasswordRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
    on<ToggleBiometric>(_onToggleBiometric);
  }
  final AuthRepository _authRepository;

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.isAuthenticated();

    if (result.isLeft()) {
      emit(Unauthenticated());
      return;
    }

    final isAuthenticated = result.getOrElse(() => false);
    if (isAuthenticated) {
      final userResult = await _authRepository.getCurrentUser();
      userResult.fold(
        (failure) => emit(Unauthenticated()),
        (user) => emit(Authenticated(user: user!)),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) {
        AppLogger.warning('Login failed: ${failure.message}');
        emit(AuthError(message: failure.message));
        emit(Unauthenticated());
      },
      (user) {
        AppLogger.info('Login successful: ${user.email}');
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.register(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
      studentId: event.studentId,
    );

    result.fold(
      (failure) {
        AppLogger.warning('Registration failed: ${failure.message}');
        emit(AuthError(message: failure.message));
        emit(Unauthenticated());
      },
      (user) {
        AppLogger.info('Registration successful: ${user.email}');
        emit(Authenticated(user: user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.logout();

    result.fold(
      (failure) {
        AppLogger.error('Logout error: ${failure.message}');
        // Still emit unauthenticated even if logout fails
        emit(Unauthenticated());
      },
      (_) {
        AppLogger.info('Logout successful');
        emit(Unauthenticated());
      },
    );
  }

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    // First check if biometric is enabled
    final isEnabledResult = await _authRepository.isBiometricEnabled();

    final isEnabled = isEnabledResult.getOrElse(() => false);

    if (!isEnabled) {
      emit(const AuthError(
        message:
            'Biometric authentication is not enabled. Please login with password first.',
      ),);
      emit(Unauthenticated());
      return;
    }

    // Attempt biometric authentication
    final authResult = await _authRepository.authenticateWithBiometrics(
      localizedReason: 'Authenticate to access SmartCampus',
    );

    authResult.fold(
      (failure) {
        AppLogger.warning(
            'Biometric authentication failed: ${failure.message}',);
        emit(AuthError(message: failure.message));
        emit(Unauthenticated());
      },
      (success) async {
        if (success) {
          // Get current user after successful biometric auth
          final userResult = await _authRepository.getCurrentUser();
          userResult.fold(
            (failure) {
              emit(AuthError(message: failure.message));
              emit(Unauthenticated());
            },
            (user) {
              AppLogger.info('Biometric login successful');
              emit(Authenticated(user: user!, isBiometric: true));
            },
          );
        } else {
          emit(const AuthError(message: 'Biometric authentication failed'));
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.isAuthenticated();

    if (result.isLeft()) {
      emit(Unauthenticated());
      return;
    }

    final isAuthenticated = result.getOrElse(() => false);
    if (isAuthenticated) {
      final userResult = await _authRepository.getCurrentUser();
      userResult.fold(
        (failure) => emit(Unauthenticated()),
        (user) => emit(Authenticated(user: user!)),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;
    emit(AuthLoading());

    final result = await _authRepository.updateProfile(
      firstName: event.firstName,
      lastName: event.lastName,
      avatarUrl: event.avatarUrl,
      department: event.department,
    );

    result.fold(
      (failure) {
        AppLogger.error('Profile update failed: ${failure.message}');
        emit(AuthError(message: failure.message));
        emit(Authenticated(user: currentUser));
      },
      (updatedUser) {
        AppLogger.info('Profile updated successfully');
        emit(Authenticated(user: updatedUser));
      },
    );
  }

  Future<void> _onChangePasswordRequested(
    ChangePasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;
    emit(AuthLoading());

    final result = await _authRepository.changePassword(
      currentPassword: event.currentPassword,
      newPassword: event.newPassword,
    );

    result.fold(
      (failure) {
        AppLogger.error('Password change failed: ${failure.message}');
        emit(AuthError(message: failure.message));
        emit(Authenticated(user: currentUser));
      },
      (_) {
        AppLogger.info('Password changed successfully');
        emit(const PasswordChangedSuccess());
        emit(Authenticated(user: currentUser));
      },
    );
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await _authRepository.resetPassword(email: event.email);

    result.fold(
      (failure) {
        AppLogger.error('Password reset failed: ${failure.message}');
        emit(AuthError(message: failure.message));
        emit(Unauthenticated());
      },
      (_) {
        AppLogger.info('Password reset email sent');
        emit(const PasswordResetEmailSent());
        emit(Unauthenticated());
      },
    );
  }

  Future<void> _onToggleBiometric(
    ToggleBiometric event,
    Emitter<AuthState> emit,
  ) async {
    if (state is! Authenticated) return;

    final currentUser = (state as Authenticated).user;

    final result = await _authRepository.setBiometricEnabled(event.enabled);

    result.fold(
      (failure) {
        AppLogger.error('Toggle biometric failed: ${failure.message}');
        emit(AuthError(message: failure.message));
        emit(Authenticated(user: currentUser));
      },
      (_) {
        AppLogger.info('Biometric setting updated: ${event.enabled}');
        emit(BiometricToggled(enabled: event.enabled));
        emit(Authenticated(user: currentUser));
      },
    );
  }
}
