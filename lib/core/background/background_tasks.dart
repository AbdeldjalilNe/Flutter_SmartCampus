import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import '../notifications/notification_service.dart';
import '../utils/dependency_injection.dart';
import '../utils/logger.dart';

class BackgroundTasks {
  // Task names
  static const String periodicSyncTask = 'periodicSyncTask';
  static const String notificationTask = 'notificationTask';
  static const String dataCleanupTask = 'dataCleanupTask';
  static const String locationUpdateTask = 'locationUpdateTask';
  
  // Task frequencies
  static const Duration periodicSyncFrequency = Duration(hours: 6);
  static const Duration notificationCheckFrequency = Duration(hours: 1);
  
  static Future<void> registerTasks() async {
    // Register periodic sync task
    await Workmanager().registerPeriodicTask(
      periodicSyncTask,
      periodicSyncTask,
      frequency: periodicSyncFrequency,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
    
    // Register notification check task
    await Workmanager().registerPeriodicTask(
      notificationTask,
      notificationTask,
      frequency: notificationCheckFrequency,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
    
    AppLogger.info('Background tasks registered');
  }
  
  static Future<void> cancelAllTasks() async {
    await Workmanager().cancelAll();
    AppLogger.info('All background tasks cancelled');
  }
  
  static Future<void> cancelTask(String taskName) async {
    await Workmanager().cancelByUniqueName(taskName);
    AppLogger.info('Background task cancelled: $taskName');
  }
  
  // Task implementations
  static Future<bool> performPeriodicSync() async {
    try {
      AppLogger.info('Performing periodic sync in background');
      
      // Sync announcements
      await _syncAnnouncements();
      
      // Sync events
      await _syncEvents();
      
      // Clean up old cache
      await _cleanupOldCache();
      
      AppLogger.info('Periodic sync completed successfully');
      return true;
    } catch (e) {
      AppLogger.error('Error in periodic sync', e);
      return false;
    }
  }
  
  static Future<bool> showScheduledNotification() async {
    try {
      AppLogger.info('Checking scheduled notifications');
      
      // Get upcoming classes and events
      final upcomingItems = await _getUpcomingItems();
      
      for (final item in upcomingItems) {
        final notificationService = getIt<NotificationService>();
        
        if (item['type'] == 'class') {
          await notificationService.scheduleClassReminder(
            classId: item['id'] as String,
            courseName: item['title'] as String,
            room: item['location'] as String,
            classTime: DateTime.parse(item['time'] as String),
            reminderMinutesBefore: (item['reminderMinutes'] as int?) ?? 10,
          );
        } else if (item['type'] == 'event') {
          await notificationService.scheduleNotification(
            id: (item['id'] as String).hashCode,
            title: 'Event: ${item['title']}',
            body: 'Starting soon at ${item['location']}',
            scheduledDate: DateTime.parse(item['time'] as String).subtract(
              const Duration(minutes: 15),
            ),
            payload: jsonEncode({
              'type': 'event',
              'id': item['id'],
            }),
          );
        }
      }
      
      AppLogger.info('Scheduled notifications processed');
      return true;
    } catch (e) {
      AppLogger.error('Error scheduling notifications', e);
      return false;
    }
  }
  
  static Future<bool> performDataCleanup() async {
    try {
      AppLogger.info('Performing data cleanup');
      
      // Clean expired cache
      await _cleanupExpiredCache();
      
      // Clean old notifications
      await _cleanupOldNotifications();
      
      // Optimize database
      await _optimizeDatabase();
      
      AppLogger.info('Data cleanup completed');
      return true;
    } catch (e) {
      AppLogger.error('Error in data cleanup', e);
      return false;
    }
  }
  
  static Future<bool> performLocationUpdate() async {
    try {
      AppLogger.info('Performing background location update');
      
      // Get current location
      // Update user's location on server if needed
      // Check for geofenced areas
      
      AppLogger.info('Location update completed');
      return true;
    } catch (e) {
      AppLogger.error('Error in location update', e);
      return false;
    }
  }
  
  // Helper methods
  static Future<void> _syncAnnouncements() async {
    AppLogger.info('Syncing announcements in background');
    // Implement announcement sync
  }
  
  static Future<void> _syncEvents() async {
    AppLogger.info('Syncing events in background');
    // Implement event sync
  }
  
  static Future<void> _cleanupOldCache() async {
    AppLogger.info('Cleaning up old cache');
    // Implement cache cleanup
  }
  
  static Future<void> _cleanupExpiredCache() async {
    AppLogger.info('Cleaning expired cache');
    // Implement expired cache cleanup
  }
  
  static Future<void> _cleanupOldNotifications() async {
    AppLogger.info('Cleaning old notifications');
    // Implement notification cleanup
  }
  
  static Future<void> _optimizeDatabase() async {
    AppLogger.info('Optimizing database');
    // Implement database optimization
  }
  
  static Future<List<Map<String, dynamic>>> _getUpcomingItems() async {
    // Get upcoming classes and events from local database
    return [];
  }
}

// Background service for managing background execution
class BackgroundService {
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await BackgroundTasks.registerTasks();
    _isInitialized = true;
    
    AppLogger.info('Background service initialized');
  }
  
  Future<void> scheduleOneTimeTask({
    required String taskName,
    required Duration delay,
    Map<String, dynamic>? inputData,
  }) async {
    await Workmanager().registerOneOffTask(
      taskName,
      taskName,
      initialDelay: delay,
      inputData: inputData,
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
    
    AppLogger.info('One-time task scheduled: $taskName');
  }
  
  Future<void> cancelAllTasks() async {
    await BackgroundTasks.cancelAllTasks();
  }
  
  Future<void> cancelTask(String taskName) async {
    await BackgroundTasks.cancelTask(taskName);
  }
}
