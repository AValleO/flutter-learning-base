import 'package:flutter_application_4/core/network/api_client.dart';

/// Example: Posts Data Source using ApiClient
/// Shows how easy it is to create new data sources without duplicating error handling
abstract class PostsRemoteDataSource {
  Future<List<Map<String, dynamic>>> getPosts();
  Future<Map<String, dynamic>> getPostById(String id);
  Future<Map<String, dynamic>> createPost(String title, String content);
  Future<void> deletePost(String id);
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final ApiClient apiClient;

  PostsRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getPosts() async {
    final response = await apiClient.get('/posts');
    // ApiClient handles ALL status codes, token injection, etc.
    return List<Map<String, dynamic>>.from(response['posts'] ?? response);
  }

  @override
  Future<Map<String, dynamic>> getPostById(String id) async {
    final response = await apiClient.get('/posts/$id');
    return response['post'] ?? response;
  }

  @override
  Future<Map<String, dynamic>> createPost(String title, String content) async {
    final response = await apiClient.post(
      '/posts',
      body: {
        'title': title,
        'content': content,
      },
    );
    return response['post'] ?? response;
  }

  @override
  Future<void> deletePost(String id) async {
    await apiClient.delete('/posts/$id');
    // That's it! All error handling is automatic
  }
}

/// Example: Products Data Source
class ProductsRemoteDataSourceImpl {
  final ApiClient apiClient;

  ProductsRemoteDataSourceImpl({required this.apiClient});

  Future<List<Map<String, dynamic>>> getProducts({int page = 1}) async {
    final response = await apiClient.get('/products?page=$page');
    return List<Map<String, dynamic>>.from(response['products'] ?? []);
  }

  Future<Map<String, dynamic>> searchProducts(String query) async {
    final response = await apiClient.get('/products/search?q=$query');
    return response;
  }
}

/// Example: Profile Data Source
class ProfileRemoteDataSourceImpl {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  Future<Map<String, dynamic>> getProfile() async {
    // Token is automatically included in headers!
    final response = await apiClient.get('/profile');
    return response['profile'] ?? response;
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await apiClient.put('/profile', body: data);
    return response['profile'] ?? response;
  }
}
