import 'package:dio/dio.dart';

/// Auth Interceptor - Handles authentication token injection
class AuthInterceptor extends Interceptor {
  String? _token;

  /// Set authentication token
  void setToken(String token) {
    _token = token;
  }

  /// Clear authentication token
  void clearToken() {
    _token = null;
  }

  /// Get current token
  String? get token => _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Inject token into every request if available
    if (_token != null) {
      options.headers['Authorization'] = 'Bearer $_token';
    }

    // Continue with the request
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Clear token on 401 Unauthorized
    if (err.response?.statusCode == 401) {
      _token = null;
    }

    super.onError(err, handler);
  }
}
