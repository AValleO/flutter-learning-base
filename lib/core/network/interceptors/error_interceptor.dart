import 'package:dio/dio.dart';
import 'package:flutter_application_4/core/errors/exceptions.dart';

/// Error Interceptor - Handles HTTP errors and converts to app exceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;

    // Extract error message from response
    String errorMessage = _extractErrorMessage(data);

    // Convert DioException to app-specific exceptions
    Exception exception;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        exception = NetworkException('Connection timeout. Please check your internet connection.');
        break;

      case DioExceptionType.badResponse:
        exception = _handleStatusCode(statusCode, errorMessage);
        break;

      case DioExceptionType.cancel:
        exception = NetworkException('Request was cancelled');
        break;

      case DioExceptionType.connectionError:
        exception = NetworkException('No internet connection');
        break;

      case DioExceptionType.unknown:
        exception = NetworkException('Network error occurred: ${err.message}');
        break;

      default:
        exception = ServerException(errorMessage);
    }

    // Reject with custom exception
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: exception,
      ),
    );
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'An error occurred';

    if (data is Map) {
      // Try common error message fields
      return data['message'] ?? 
             data['error'] ?? 
             data['detail'] ?? 
             data['msg'] ?? 
             'An error occurred';
    }

    if (data is String) {
      return data;
    }

    return 'An error occurred';
  }

  /// Handle specific HTTP status codes
  Exception _handleStatusCode(int? statusCode, String message) {
    switch (statusCode) {
      case 400:
        return ServerException('Bad Request: $message');

      case 401:
        return ServerException('Unauthorized: $message');

      case 403:
        return ServerException('Forbidden: $message');

      case 404:
        return ServerException('Not Found: $message');

      case 409:
        return ServerException('Conflict: $message');

      case 422:
        return ServerException('Validation Error: $message');

      case 429:
        return ServerException('Too Many Requests: Please try again later');

      case 500:
        return ServerException('Internal Server Error: $message');

      case 502:
        return ServerException('Bad Gateway: Server is temporarily unavailable');

      case 503:
        return ServerException('Service Unavailable: $message');

      default:
        return ServerException('HTTP Error $statusCode: $message');
    }
  }
}
