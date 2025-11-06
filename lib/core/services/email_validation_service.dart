import 'package:flutter_application_4/core/network/dio_client.dart';

/// Service for validating email availability against company API
class EmailValidationService {
  final DioClient _client;

  EmailValidationService(this._client);

  /// Check if email is already registered
  /// Returns true if email is available, false if already exists
  Future<bool> checkEmailAvailability(String email) async {
    try {
      // Simulating API call to company email validation endpoint
      // Replace with your actual endpoint
      final response = await _client.get(
        '/auth/check-email',
        queryParameters: {'email': email},
      );
      
      // Assuming API returns: {"available": true/false}
      return response.data['available'] as bool;
    } catch (e) {
      // If API fails, allow the email (don't block user)
      // You could also show a warning in UI
      return true;
    }
  }

  /// Debounced validation (wait for user to stop typing)
  Future<bool> validateEmailDebounced(
    String email, {
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    // Wait for delay period
    await Future.delayed(delay);
    
    // Then check availability
    return checkEmailAvailability(email);
  }
}
