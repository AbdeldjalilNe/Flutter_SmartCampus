part of 'lifecycle_bloc.dart';

enum LifecycleStatus {
  initial,
  resumed,
  inactive,
  paused,
  detached,
  hidden,
}

class LifecycleState extends Equatable {
  const LifecycleState({
    this.status = LifecycleStatus.initial,
    this.isInBackground = false,
    this.isUserActive = true,
    this.isSessionExpired = false,
    this.isConnected = true,
    this.isLowMemory = false,
    this.needsDataRefresh = false,
    this.backgroundEntryTime,
    this.lastUserActivity,
  });
  final LifecycleStatus status;
  final bool isInBackground;
  final bool isUserActive;
  final bool isSessionExpired;
  final bool isConnected;
  final bool isLowMemory;
  final bool needsDataRefresh;
  final DateTime? backgroundEntryTime;
  final DateTime? lastUserActivity;

  LifecycleState copyWith({
    LifecycleStatus? status,
    bool? isInBackground,
    bool? isUserActive,
    bool? isSessionExpired,
    bool? isConnected,
    bool? isLowMemory,
    bool? needsDataRefresh,
    DateTime? backgroundEntryTime,
    DateTime? lastUserActivity,
  }) =>
      LifecycleState(
        status: status ?? this.status,
        isInBackground: isInBackground ?? this.isInBackground,
        isUserActive: isUserActive ?? this.isUserActive,
        isSessionExpired: isSessionExpired ?? this.isSessionExpired,
        isConnected: isConnected ?? this.isConnected,
        isLowMemory: isLowMemory ?? this.isLowMemory,
        needsDataRefresh: needsDataRefresh ?? this.needsDataRefresh,
        backgroundEntryTime: backgroundEntryTime ?? this.backgroundEntryTime,
        lastUserActivity: lastUserActivity ?? this.lastUserActivity,
      );

  Duration? get timeInBackground {
    if (backgroundEntryTime == null) return null;
    return DateTime.now().difference(backgroundEntryTime!);
  }

  bool get isOnline => isConnected;
  bool get isOffline => !isConnected;

  @override
  List<Object?> get props => [
        status,
        isInBackground,
        isUserActive,
        isSessionExpired,
        isConnected,
        isLowMemory,
        needsDataRefresh,
        backgroundEntryTime,
        lastUserActivity,
      ];
}
