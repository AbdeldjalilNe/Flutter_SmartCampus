part of 'lifecycle_bloc.dart';

abstract class LifecycleEvent extends Equatable {
  const LifecycleEvent();

  @override
  List<Object?> get props => [];
}

class AppResumed extends LifecycleEvent {}

class AppPaused extends LifecycleEvent {}

class AppInactive extends LifecycleEvent {}

class AppDetached extends LifecycleEvent {}

class AppHidden extends LifecycleEvent {}

class UserBecameActive extends LifecycleEvent {}

class UserBecameInactive extends LifecycleEvent {}

class SessionExpired extends LifecycleEvent {}

class BackgroundDataRefreshNeeded extends LifecycleEvent {}

class LowMemoryWarning extends LifecycleEvent {}

class ConnectivityChanged extends LifecycleEvent {
  const ConnectivityChanged({required this.isConnected});
  final bool isConnected;

  @override
  List<Object?> get props => [isConnected];
}
