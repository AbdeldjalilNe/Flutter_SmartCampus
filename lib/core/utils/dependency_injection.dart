import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:local_auth/local_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../constants/app_constants.dart';
import '../lifecycle/app_lifecycle_observer.dart';
import '../network/dio_client.dart';
import '../notifications/notification_service.dart';
import '../background/background_service.dart';
import '../permissions/permission_handler.dart';
import '../storage/secure_storage.dart';
import '../storage/local_database.dart';

import '../../data/datasources/local/auth_local_datasource.dart';
import '../../data/datasources/local/announcement_local_datasource.dart';
import '../../data/datasources/local/event_local_datasource.dart';
import '../../data/datasources/local/timetable_local_datasource.dart';
import '../../data/datasources/local/settings_local_datasource.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/announcement_remote_datasource.dart';
import '../../data/datasources/remote/event_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/announcement_repository_impl.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/repositories/timetable_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/announcement_repository.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/repositories/timetable_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/lifecycle/lifecycle_bloc.dart';
import '../../presentation/bloc/localization/localization_bloc.dart';
import '../../presentation/bloc/announcement/announcement_bloc.dart';
import '../../presentation/bloc/event/event_bloc.dart';
import '../../presentation/bloc/timetable/timetable_bloc.dart';
import '../../presentation/bloc/settings/settings_bloc.dart';
import '../../presentation/bloc/qr_scanner/qr_scanner_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accountName: 'flutter_secure_storage',
    ),
  );
  getIt.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);

  getIt.registerLazySingleton<Connectivity>(Connectivity.new);
  getIt.registerLazySingleton<LocalAuthentication>(LocalAuthentication.new);
  getIt.registerLazySingleton<GeolocatorPlatform>(
    () => GeolocatorPlatform.instance,
  );
  getIt.registerLazySingleton<ImagePicker>(ImagePicker.new);
  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin.new,
  );

  // Initialize Database
  final database = await _initDatabase();
  getIt.registerLazySingleton<Database>(() => database);

  // Core Services
  getIt.registerLazySingleton<SecureStorageService>(
    () => SecureStorageService(getIt()),
  );

  getIt.registerLazySingleton<LocalDatabaseService>(
    () => LocalDatabaseService(getIt()),
  );

  getIt.registerLazySingleton<PermissionHandlerService>(
    PermissionHandlerService.new,
  );

  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(getIt()),
  );

  getIt.registerLazySingleton<BackgroundService>(
    BackgroundService.new,
  );

  getIt.registerLazySingleton<AppLifecycleObserver>(
    AppLifecycleObserver.new,
  );

  // Network
  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt()),
  );

  // DataSources - Local
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: getIt(),
      sharedPreferences: getIt(),
    ),
  );

  getIt.registerLazySingleton<AnnouncementLocalDataSource>(
    () => AnnouncementLocalDataSourceImpl(
      sharedPreferences: getIt(),
    ),
  );

  getIt.registerLazySingleton<EventLocalDataSource>(
    () => EventLocalDataSourceImpl(
      sharedPreferences: getIt(),
    ),
  );

  getIt.registerLazySingleton<TimetableLocalDataSource>(
    () => TimetableLocalDataSourceImpl(
      sharedPreferences: getIt(),
    ),
  );

  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(
      sharedPreferences: getIt(),
    ),
  );

  // DataSources - Remote
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(getIt()),
  );

  getIt.registerLazySingleton<AnnouncementRemoteDataSource>(
    () => AnnouncementRemoteDataSourceImpl(),
  );

  getIt.registerLazySingleton<EventRemoteDataSource>(
    () => EventRemoteDataSourceImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      localAuth: getIt(),
    ),
  );

  getIt.registerLazySingleton<AnnouncementRepository>(
    () => AnnouncementRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      connectivity: getIt(),
    ),
  );

  getIt.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      connectivity: getIt(),
    ),
  );

  getIt.registerLazySingleton<TimetableRepository>(
    () => TimetableRepositoryImpl(
      localDataSource: getIt(),
    ),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(
      localDataSource: getIt(),
    ),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt()),
  );

  getIt.registerFactory<LifecycleBloc>(
    LifecycleBloc.new,
  );

  getIt.registerFactory<LocalizationBloc>(
    () => LocalizationBloc(settingsRepository: getIt()),
  );

  getIt.registerFactory<AnnouncementBloc>(
    () => AnnouncementBloc(repository: getIt()),
  );

  getIt.registerFactory<EventBloc>(
    () => EventBloc(repository: getIt()),
  );

  getIt.registerFactory<TimetableBloc>(
    () => TimetableBloc(repository: getIt()),
  );

  getIt.registerFactory<SettingsBloc>(
    () => SettingsBloc(repository: getIt()),
  );

  getIt.registerFactory<QrScannerBloc>(
    QrScannerBloc.new,
  );

  // Initialize notification service
  await getIt<NotificationService>().initialize();
}

Future<Database> _initDatabase() async {
  final databasesPath = await getDatabasesPath();
  final path = join(databasesPath, AppConstants.databaseName);

  return openDatabase(
    path,
    version: AppConstants.databaseVersion,
    onCreate: (db, version) async {
      // Create announcements table
      await db.execute('''
        CREATE TABLE announcements (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          content TEXT NOT NULL,
          author TEXT NOT NULL,
          category TEXT NOT NULL,
          priority INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          expires_at TEXT,
          image_url TEXT,
          is_read INTEGER DEFAULT 0,
          cached_at TEXT NOT NULL
        )
      ''');

      // Create events table
      await db.execute('''
        CREATE TABLE events (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          location TEXT NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          organizer TEXT NOT NULL,
          category TEXT NOT NULL,
          max_attendees INTEGER,
          current_attendees INTEGER DEFAULT 0,
          image_url TEXT,
          requires_check_in INTEGER DEFAULT 0,
          cached_at TEXT NOT NULL
        )
      ''');

      // Create timetable table
      await db.execute('''
        CREATE TABLE timetable_items (
          id TEXT PRIMARY KEY,
          course_name TEXT NOT NULL,
          course_code TEXT NOT NULL,
          instructor TEXT NOT NULL,
          room TEXT NOT NULL,
          day_of_week INTEGER NOT NULL,
          start_time TEXT NOT NULL,
          end_time TEXT NOT NULL,
          color INTEGER,
          notification_enabled INTEGER DEFAULT 1,
          reminder_minutes INTEGER DEFAULT 10
        )
      ''');

      // Create check-ins table for QR code events
      await db.execute('''
        CREATE TABLE check_ins (
          id TEXT PRIMARY KEY,
          event_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          check_in_time TEXT NOT NULL,
          qr_code_data TEXT,
          FOREIGN KEY (event_id) REFERENCES events(id)
        )
      ''');
    },
  );
}
