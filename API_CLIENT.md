# API Client & Interceptor Pattern

## Overview

The `ApiClient` provides centralized HTTP request handling with automatic:
- ✅ Token management (authentication)
- ✅ Error handling (status codes)
- ✅ Header injection
- ✅ Request/response formatting

## Benefits

### Before (Duplicated Code) ❌

```dart
class AuthRemoteDataSourceImpl {
  Future<UserModel> register(...) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({...}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return UserModel.fromJson(jsonResponse['user'] ?? jsonResponse);
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw ServerException(error['message'] ?? 'Registration failed');
      } else if (response.statusCode == 401) {
        throw ServerException('Unauthorized');
      } else {
        throw ServerException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw NetworkException('Failed to connect to server');
    }
  }
  
  // Same duplicate code for login, logout, etc.
}
```

**Problems:**
- 🔴 Duplicate error handling in EVERY method
- 🔴 Manual JSON encoding/decoding
- 🔴 Manual header management
- 🔴 Manual token injection
- 🔴 Hard to maintain

### After (ApiClient) ✅

```dart
class AuthRemoteDataSourceImpl {
  final ApiClient apiClient;

  Future<UserModel> register(...) async {
    final response = await apiClient.post(
      '/auth/register',
      body: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    
    return UserModel.fromJson(response['user'] ?? response);
  }
  
  // 5 lines instead of 25!
}
```

**Benefits:**
- ✅ No duplicate error handling
- ✅ Automatic JSON encoding/decoding
- ✅ Automatic header injection
- ✅ Automatic token management
- ✅ Easy to maintain

## Usage

### 1. Basic GET Request

```dart
final response = await apiClient.get('/users');
// Returns: Map<String, dynamic>
// Throws: ServerException on error
```

### 2. POST with Body

```dart
final response = await apiClient.post(
  '/posts',
  body: {
    'title': 'My Post',
    'content': 'Post content',
  },
);
```

### 3. Authenticated Requests

```dart
// Set token after login
apiClient.setToken('your_jwt_token_here');

// All subsequent requests include token automatically
final profile = await apiClient.get('/profile');
// Header: Authorization: Bearer your_jwt_token_here

// Clear token on logout
apiClient.clearToken();
```

### 4. Custom Headers

```dart
final response = await apiClient.post(
  '/upload',
  body: data,
  headers: {
    'X-Custom-Header': 'value',
    'X-Request-ID': '12345',
  },
);
```

## Status Code Handling

The ApiClient automatically handles all HTTP status codes:

| Status Code | Action |
|------------|--------|
| 200-299 | ✅ Success - Returns parsed JSON |
| 400 | ❌ Throws: "Bad Request: {message}" |
| 401 | ❌ Throws: "Unauthorized: {message}" + Clears token |
| 403 | ❌ Throws: "Forbidden: {message}" |
| 404 | ❌ Throws: "Not Found: {message}" |
| 409 | ❌ Throws: "Conflict: {message}" |
| 422 | ❌ Throws: "Validation Error: {message}" |
| 429 | ❌ Throws: "Too Many Requests" |
| 500 | ❌ Throws: "Internal Server Error: {message}" |
| 502 | ❌ Throws: "Bad Gateway" |
| 503 | ❌ Throws: "Service Unavailable: {message}" |
| Other | ❌ Throws: "HTTP Error {code}: {message}" |

## Token Management

### Automatic Token Injection

```dart
// 1. Login and receive token
final loginResponse = await apiClient.post('/auth/login', body: {...});

// 2. Store token
apiClient.setToken(loginResponse['token']);

// 3. All requests now include token automatically
await apiClient.get('/profile');        // ✅ Includes token
await apiClient.get('/posts');          // ✅ Includes token
await apiClient.post('/posts', ...);    // ✅ Includes token

// 4. Logout clears token
apiClient.clearToken();
```

### Token Persistence

For persistent token storage, integrate with local data source:

```dart
// After login
final token = response['token'];
apiClient.setToken(token);
await localDataSource.saveToken(token);

// On app start
final cachedToken = await localDataSource.getToken();
if (cachedToken != null) {
  apiClient.setToken(cachedToken);
}
```

## Error Message Parsing

The ApiClient tries multiple fields to extract error messages:

```dart
// API returns: {"message": "Email already exists"}
// Exception: "Bad Request: Email already exists"

// API returns: {"error": "Invalid credentials"}
// Exception: "Unauthorized: Invalid credentials"

// API returns: {"detail": "Resource not found"}
// Exception: "Not Found: Resource not found"

// API returns: {"status": 500}
// Exception: "Internal Server Error: An error occurred"
```

## Creating New Data Sources

### Template

```dart
import 'package:flutter_application_4/core/network/api_client.dart';

abstract class MyFeatureRemoteDataSource {
  Future<MyModel> getData();
  Future<MyModel> createData(Map<String, dynamic> data);
}

class MyFeatureRemoteDataSourceImpl implements MyFeatureRemoteDataSource {
  final ApiClient apiClient;

  MyFeatureRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MyModel> getData() async {
    final response = await apiClient.get('/my-endpoint');
    return MyModel.fromJson(response);
  }

  @override
  Future<MyModel> createData(Map<String, dynamic> data) async {
    final response = await apiClient.post('/my-endpoint', body: data);
    return MyModel.fromJson(response);
  }
}
```

### Register in DI

```dart
// injection_container.dart
getIt.registerLazySingleton<MyFeatureRemoteDataSource>(
  () => MyFeatureRemoteDataSourceImpl(
    apiClient: getIt(),
  ),
);
```

## Advanced: Custom Interceptors

If you need more advanced features, consider using `dio` package with interceptors:

```bash
flutter pub add dio
```

```dart
import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  String? token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle token refresh or logout
    }
    super.onError(err, handler);
  }
}
```

## Configuration

Update base URL in `injection_container.dart`:

```dart
getIt.registerLazySingleton(
  () => ApiClient(
    client: getIt(),
    baseUrl: 'https://your-api.com',  // ← Change this
  ),
);
```

## Summary

✅ **One place** for all HTTP logic  
✅ **No duplication** across data sources  
✅ **Automatic** token management  
✅ **Automatic** error handling  
✅ **Easy to extend** with new endpoints  
✅ **Maintainable** and testable  

Your data sources are now **5x shorter** and **much cleaner**! 🎉
