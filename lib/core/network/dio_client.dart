import 'package:dio/dio.dart';
import 'package:flutter_application_4/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_application_4/core/network/interceptors/error_interceptor.dart';
import 'package:flutter_application_4/core/network/interceptors/logging_interceptor.dart';

/// Dio-based HTTP client with interceptors
class DioClient {
  late final Dio dio;
  late final AuthInterceptor _authInterceptor;

  DioClient({
    required String baseUrl,
    int connectTimeout = 30,
    int receiveTimeout = 30,
  }) {
    // Create auth interceptor instance
    _authInterceptor = AuthInterceptor();

    // Configure Dio
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: connectTimeout),
        receiveTimeout: Duration(seconds: receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors in order
    dio.interceptors.addAll([
      _authInterceptor,      // 1. Inject auth token
      ErrorInterceptor(),    // 2. Handle errors
      LoggingInterceptor(),  // 3. Log requests (debug only)
    ]);
  }

  /// Set authentication token
  void setToken(String token) {
    _authInterceptor.setToken(token);
  }

  /// Clear authentication token
  void clearToken() {
    _authInterceptor.clearToken();
  }

  /// Get current token
  String? get token => _authInterceptor.token;

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Upload file
  Future<Response> upload(
    String path,
    FormData formData, {
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    return await dio.post(
      path,
      data: formData,
      options: options,
      onSendProgress: onSendProgress,
    );
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Options? options,
  }) async {
    return await dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      options: options,
    );
  }
}
