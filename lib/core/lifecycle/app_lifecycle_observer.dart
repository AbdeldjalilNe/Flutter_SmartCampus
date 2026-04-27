import 'dart:async';
import 'package:flutter/material.dart';
import '../../presentation/bloc/lifecycle/lifecycle_bloc.dart';
import '../utils/dependency_injection.dart';
import '../utils/logger.dart';

class AppLifecycleObserver {
  late LifecycleBloc _lifecycleBloc;
  Timer? _backgroundTimer;
  DateTime? _backgroundEntryTime;

  // Configuration
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration backgroundRefreshInterval = Duration(minutes: 15);

  void initialize() {
    _lifecycleBloc = getIt<LifecycleBloc>();
    AppLogger.info('AppLifecycleObserver initialized');
  }

  void dispose() {
    _backgroundTimer?.cancel();
    AppLogger.info('AppLifecycleObserver disposed');
  }

  void handleLifecycleState(AppLifecycleState state) {
    AppLogger.info('App lifecycle state changed: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        _onResumed();
        break;
      case AppLifecycleState.inactive:
        _onInactive();
        break;
      case AppLifecycleState.paused:
        _onPaused();
        break;
      case AppLifecycleState.detached:
        _onDetached();
        break;
      case AppLifecycleState.hidden:
        _onHidden();
        break;
    }
  }

  void _onResumed() {
    AppLogger.info('App resumed from background');

    _lifecycleBloc.add(AppResumed());

    // Cancel background timer
    _backgroundTimer?.cancel();
    _backgroundTimer = null;

    // Check if session expired while in background
    if (_backgroundEntryTime != null) {
      final timeInBackground = DateTime.now().difference(_backgroundEntryTime!);
      AppLogger.info('App was in background for: $timeInBackground');

      if (timeInBackground > sessionTimeout) {
        AppLogger.warning('Session expired due to long background time');
        _lifecycleBloc.add(SessionExpired());
      }

      // Check if we need to refresh data
      if (timeInBackground > backgroundRefreshInterval) {
        AppLogger.info('Triggering background data refresh');
        _lifecycleBloc.add(BackgroundDataRefreshNeeded());
      }
    }

    _backgroundEntryTime = null;

    // Resume any paused operations
    _resumeOperations();
  }

  void _onInactive() {
    AppLogger.info('App became inactive');
    _lifecycleBloc.add(AppInactive());

    // Pause non-essential operations
    _pauseOperations();
  }

  void _onPaused() {
    AppLogger.info('App paused - entering background');

    _backgroundEntryTime = DateTime.now();
    _lifecycleBloc.add(AppPaused());

    // Start background timer for periodic tasks
    _startBackgroundTimer();

    // Save app state
    _saveAppState();

    // Release resources
    _releaseResources();
  }

  void _onDetached() {
    AppLogger.info('App detached');
    _lifecycleBloc.add(AppDetached());

    // Clean up resources
    _cleanup();
  }

  void _onHidden() {
    AppLogger.info('App hidden');
    _lifecycleBloc.add(AppHidden());
  }

  void _startBackgroundTimer() {
    _backgroundTimer?.cancel();
    _backgroundTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) {
        AppLogger.info('Background timer tick - performing background tasks');
        _performBackgroundTasks();
      },
    );
  }

  void _performBackgroundTasks() {
    // These tasks run periodically while app is in background
    // Note: Actual background execution is limited by OS

    try {
      // Sync pending data
      _syncPendingData();

      // Update location if needed
      _updateLocation();

      // Check for new notifications
      _checkNotifications();
    } catch (e) {
      AppLogger.error('Error in background tasks', e);
    }
  }

  void _syncPendingData() {
    AppLogger.info('Syncing pending data in background');
    // Implement data sync logic
  }

  void _updateLocation() {
    AppLogger.info('Updating location in background');
    // Implement location update logic
  }

  void _checkNotifications() {
    AppLogger.info('Checking for new notifications');
    // Implement notification check logic
  }

  void _saveAppState() {
    AppLogger.info('Saving app state before background');
    // Persist any unsaved state
  }

  void _releaseResources() {
    AppLogger.info('Releasing resources for background');
    // Release memory-intensive resources
    // Pause animations
    // Stop sensors
  }

  void _resumeOperations() {
    AppLogger.info('Resuming operations');
    // Resume animations
    // Restart sensors
    // Refresh UI data
  }

  void _pauseOperations() {
    AppLogger.info('Pausing operations');
    // Pause animations
    // Stop non-essential timers
  }

  void _cleanup() {
    AppLogger.info('Cleaning up resources');
    _backgroundTimer?.cancel();
    // Final cleanup
  }

  // Public methods for external lifecycle management

  void onUserActive() {
    AppLogger.info('User became active');
    _lifecycleBloc.add(UserBecameActive());
  }

  void onUserInactive() {
    AppLogger.info('User became inactive');
    _lifecycleBloc.add(UserBecameInactive());
  }

  void onLowMemory() {
    AppLogger.warning('Low memory warning received');
    _lifecycleBloc.add(LowMemoryWarning());
    _releaseResources();
  }

  void onConnectivityChanged(bool isConnected) {
    AppLogger.info('Connectivity changed: $isConnected');
    _lifecycleBloc.add(ConnectivityChanged(isConnected: isConnected));
  }

  // Getters for state information

  bool get isInBackground => _backgroundEntryTime != null;

  Duration? get timeInBackground {
    if (_backgroundEntryTime == null) return null;
    return DateTime.now().difference(_backgroundEntryTime!);
  }

  bool get isSessionExpired {
    if (_backgroundEntryTime == null) return false;
    return DateTime.now().difference(_backgroundEntryTime!) > sessionTimeout;
  }
}

// Widget to observe app lifecycle
class AppLifecycleObserverWidget extends StatefulWidget {
  const AppLifecycleObserverWidget({
    super.key,
    required this.child,
    this.onResume,
    this.onPause,
    this.onInactive,
  });
  final Widget child;
  final VoidCallback? onResume;
  final VoidCallback? onPause;
  final VoidCallback? onInactive;

  @override
  State<AppLifecycleObserverWidget> createState() =>
      _AppLifecycleObserverWidgetState();
}

class _AppLifecycleObserverWidgetState extends State<AppLifecycleObserverWidget>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        widget.onResume?.call();
        break;
      case AppLifecycleState.paused:
        widget.onPause?.call();
        break;
      case AppLifecycleState.inactive:
        widget.onInactive?.call();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
