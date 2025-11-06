import 'package:flutter_application_4/core/errors/exceptions.dart';
import 'package:flutter_application_4/core/network/dio_client.dart';
import 'package:flutter_application_4/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({
    required this.dioClient,
  });

  @override
  Future<UserModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      // Interceptors handle all error status codes automatically
      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data['user'] ?? data);
    } catch (e) {
      // Error interceptor already converted DioException to app exceptions
      if (e is Exception) rethrow;
      throw ServerException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dioClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;

      // Extract and store token if your API returns it
      if (data['token'] != null) {
        dioClient.setToken(data['token']);
      }

      return UserModel.fromJson(data['user'] ?? data);
    } catch (e) {
      if (e is Exception) rethrow;
      throw ServerException('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post('/auth/logout');
    } finally {
      // Always clear token, even if logout request fails
      dioClient.clearToken();
    }
  }
}
