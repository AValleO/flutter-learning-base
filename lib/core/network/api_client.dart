import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_4/core/errors/exceptions.dart';

/// API Client with interceptor-like functionality
class ApiClient {
  final http.Client client;
  final String baseUrl;
  String? _authToken;

  ApiClient({
    required this.client,
    required this.baseUrl,
  });

  /// Set authentication token for subsequent requests
  void setToken(String token) {
    _authToken = token;
  }

  /// Clear authentication token
  void clearToken() {
    _authToken = null;
  }

  /// GET request with automatic error handling
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final response = await client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(headers),
    );

    return _handleResponse(response);
  }

  /// POST request with automatic error handling
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(headers),
      body: body != null ? json.encode(body) : null,
    );

    return _handleResponse(response);
  }

  /// PUT request with automatic error handling
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final response = await client.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(headers),
      body: body != null ? json.encode(body) : null,
    );

    return _handleResponse(response);
  }

  /// DELETE request with automatic error handling
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final response = await client.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(headers),
    );

    return _handleResponse(response);
  }

  /// Build headers with authentication token
  Map<String, String> _buildHeaders(Map<String, String>? customHeaders) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add authentication token if available
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    // Add custom headers
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  /// Centralized response handling - the "interceptor"
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    // Success responses (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return json.decode(response.body) as Map<String, dynamic>;
    }

    // Parse error message
    String errorMessage = 'An error occurred';
    try {
      final errorBody = json.decode(response.body);
      errorMessage = errorBody['message'] ?? 
                     errorBody['error'] ?? 
                     errorBody['detail'] ?? 
                     errorMessage;
    } catch (_) {
      // If parsing fails, use status code message
    }

    // Handle specific status codes
    switch (statusCode) {
      case 400:
        throw ServerException('Bad Request: $errorMessage');
      
      case 401:
        // Token expired or invalid credentials
        _authToken = null; // Clear invalid token
        throw ServerException('Unauthorized: $errorMessage');
      
      case 403:
        throw ServerException('Forbidden: $errorMessage');
      
      case 404:
        throw ServerException('Not Found: $errorMessage');
      
      case 409:
        throw ServerException('Conflict: $errorMessage');
      
      case 422:
        throw ServerException('Validation Error: $errorMessage');
      
      case 429:
        throw ServerException('Too Many Requests: Please try again later');
      
      case 500:
        throw ServerException('Internal Server Error: $errorMessage');
      
      case 502:
        throw ServerException('Bad Gateway: Server is temporarily unavailable');
      
      case 503:
        throw ServerException('Service Unavailable: $errorMessage');
      
      default:
        throw ServerException('HTTP Error $statusCode: $errorMessage');
    }
  }
}
