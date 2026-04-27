import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/logger.dart';

part 'lifecycle_event.dart';
part 'lifecycle_state.dart';

class LifecycleBloc extends Bloc<LifecycleEvent, LifecycleState> {
  LifecycleBloc() : super(const LifecycleState()) {
    on<AppResumed>(_onAppResumed);
    on<AppPaused>(_onAppPaused);
    on<AppInactive>(_onAppInactive);
    on<AppDetached>(_onAppDetached);
    on<AppHidden>(_onAppHidden);
    on<UserBecameActive>(_onUserBecameActive);
    on<UserBecameInactive>(_onUserBecameInactive);
    on<SessionExpired>(_onSessionExpired);
    on<BackgroundDataRefreshNeeded>(_onBackgroundDataRefreshNeeded);
    on<LowMemoryWarning>(_onLowMemoryWarning);
    on<ConnectivityChanged>(_onConnectivityChanged);
  }

  Future<void> _onAppResumed(
    AppResumed event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.info('Lifecycle: App resumed');
    emit(state.copyWith(
      status: LifecycleStatus.resumed,
      isInBackground: false,
    ),);
  }

  Future<void> _onAppPaused(
    AppPaused event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.info('Lifecycle: App paused');
    emit(state.copyWith(
      status: LifecycleStatus.paused,
      isInBackground: true,
      backgroundEntryTime: DateTime.now(),
    ),);
  }

  Future<void> _onAppInactive(
    AppInactive event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.info('Lifecycle: App inactive');
    emit(state.copyWith(
      status: LifecycleStatus.inactive,
    ),);
  }

  Future<void> _onAppDetached(
    AppDetached event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.info('Lifecycle: App detached');
    emit(state.copyWith(
      status: LifecycleStatus.detached,
    ),);
  }

  Future<void> _onAppHidden(
    AppHidden event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.info('Lifecycle: App hidden');
    emit(state.copyWith(
      status: LifecycleStatus.hidden,
    ),);
  }

  Future<void> _onUserBecameActive(
    UserBecameActive event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.info('Lifecycle: User became active');
    emit(state.copyWith(
      isUserActive: true,
      lastUserActivity: DateTime.now(),
    ),);
  }

  Future<void> _onUserBecameInactive(
    UserBecameInactive event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.info('Lifecycle: User became inactive');
    emit(state.copyWith(
      isUserActive: false,
    ),);
  }

  Future<void> _onSessionExpired(
    SessionExpired event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.warning('Lifecycle: Session expired');
    emit(state.copyWith(
      isSessionExpired: true,
    ),);
  }

  Future<void> _onBackgroundDataRefreshNeeded(
    BackgroundDataRefreshNeeded event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.info('Lifecycle: Background data refresh needed');
    emit(state.copyWith(
      needsDataRefresh: true,
    ),);
    // Reset the flag after emitting
    emit(state.copyWith(
      needsDataRefresh: false,
    ),);
  }

  Future<void> _onLowMemoryWarning(
    LowMemoryWarning event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.warning('Lifecycle: Low memory warning');
    emit(state.copyWith(
      isLowMemory: true,
    ),);
    // Reset the flag after emitting
    emit(state.copyWith(
      isLowMemory: false,
    ),);
  }

  Future<void> _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<LifecycleState> emit,
  ) async {
    AppLogger.info(
        'Lifecycle: Connectivity changed - ${event.isConnected ? 'Online' : 'Offline'}',);
    emit(state.copyWith(
      isConnected: event.isConnected,
    ),);
  }
}
