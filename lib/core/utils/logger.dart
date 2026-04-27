import 'package:logger/logger.dart';

class AppLogger {
  static late Logger _logger;
  static bool _initialized = false;

  static void init() {
    if (_initialized) return;
    
    _logger = Logger(
      printer: PrettyPrinter(
        dateTimeFormat: DateTimeFormat.dateAndTime,
      ),
      level: Level.debug,
    );
    _initialized = true;
  }

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void verbose(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  static void wtf(String message, [dynamic error, StackTrace? stackTrace]) {
    _ensureInitialized();
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  static void _ensureInitialized() {
    if (!_initialized) {
      init();
    }
  }
}

// Simple log wrapper for quick debugging
void logDebug(String message) => AppLogger.debug(message);
void logInfo(String message) => AppLogger.info(message);
void logWarning(String message) => AppLogger.warning(message);
void logError(String message, [dynamic error]) => AppLogger.error(message, error);
