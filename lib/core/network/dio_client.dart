import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import '../utils/logger.dart';

class DioClient {
  DioClient(this._connectivity) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
    _setupSSL();
  }
  late final Dio _dio;
  final Connectivity _connectivity;

  Dio get dio => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          AppLogger.info('REQUEST[${options.method}] => PATH: ${options.path}');
          AppLogger.verbose('Request Headers: ${options.headers}');
          AppLogger.verbose('Request Data: ${options.data}');

          // Check connectivity
          final connectivityResult = await _connectivity.checkConnectivity();
          if (connectivityResult == ConnectivityResult.none) {
            AppLogger.warning('No internet connection');
            throw const NetworkException(message: 'No internet connection');
          }

          // Add auth token if available
          // final token = await _getAuthToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.info(
            'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
          );
          AppLogger.verbose('Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) {
          AppLogger.error(
            'ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            error,
          );

          final exception = _handleDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: exception,
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );

    // Add logging interceptor in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => AppLogger.debug(object.toString()),
      ),
    );
  }

  void _setupSSL() {
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) {
        // In production, validate certificates properly
        // For development, you might need to handle self-signed certificates
        return true;
      };
      return client;
    };
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
            message: 'Connection timeout. Please try again.',);

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            (error.response?.data?['message'] as String?) ?? 'Server error occurred';

        switch (statusCode) {
          case 400:
            return ValidationException(message: message);
          case 401:
            return const AuthenticationException(
                message: 'Session expired. Please login again.',);
          case 403:
            return PermissionDeniedException(
              message: message,
              permission: 'API access',
            );
          case 404:
            return NotFoundException(message: message);
          case 500:
          case 502:
          case 503:
          case 504:
            return ServerException(message: message, statusCode: statusCode);
          default:
            return ServerException(message: message, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled');

      case DioExceptionType.connectionError:
        return const NetworkException(message: 'No internet connection');

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException(message: 'No internet connection');
        }
        return ServerException(
            message: error.message ?? 'Unknown error occurred',);

      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'SSL certificate error');

      default:
        return const ServerException(message: 'Something went wrong');
    }
  }

  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw e.error is Exception ? e.error! : _handleDioError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw e.error is Exception ? e.error! : _handleDioError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw e.error is Exception ? e.error! : _handleDioError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw e.error is Exception ? e.error! : _handleDioError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw e.error is Exception ? e.error! : _handleDioError(e);
    }
  }

  // Download file
  Future<Response> download(
    String urlPath,
    dynamic savePath, {
    void Function(int, int)? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    Options? options,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        options: options,
      );
    } on DioException catch (e) {
      throw e.error is Exception ? e.error! : _handleDioError(e);
    }
  }
}

// Network connectivity helper
class NetworkConnectivity {
  NetworkConnectivity(this._connectivity);
  final Connectivity _connectivity;

  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;

  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<ConnectivityResult> get connectivityResult async =>
      _connectivity.checkConnectivity();
}
