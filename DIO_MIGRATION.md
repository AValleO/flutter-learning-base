# Dio Client with Interceptors - Migration Complete ✅

## What Changed

Successfully migrated from `http` package with manual wrapper to `dio` with **true interceptors** (Angular-style).

## Architecture

```
┌─────────────────────────────────────────────┐
│         Data Source Layer                   │
│  (auth_remote_data_source.dart)            │
└─────────────────┬───────────────────────────┘
                  │ uses
                  ▼
┌─────────────────────────────────────────────┐
│           DioClient                         │
│      (dio_client.dart)                      │
│                                             │
│  ┌─────────────────────────────────────┐   │
│  │  Interceptor Chain                  │   │
│  │                                     │   │
│  │  1. AuthInterceptor                │   │
│  │     ↓ Inject Token                 │   │
│  │  2. ErrorInterceptor               │   │
│  │     ↓ Convert to App Exceptions    │   │
│  │  3. LoggingInterceptor             │   │
│  │     ↓ Log (Debug Only)             │   │
│  └─────────────────────────────────────┘   │
└─────────────────┬───────────────────────────┘
                  │
                  ▼
              Network Request
```

## Interceptors

### 1. **AuthInterceptor** 🔐
**Purpose**: Token management

**Features**:
- ✅ Injects `Authorization: Bearer {token}` header automatically
- ✅ Stores token in memory
- ✅ Clears token on 401 Unauthorized

**Usage**:
```dart
// After login
dioClient.setToken('your_jwt_token');

// All requests now authenticated automatically
await dioClient.get('/profile');  // ✅ Token included

// On logout
dioClient.clearToken();
```

### 2. **ErrorInterceptor** ❌
**Purpose**: Centralized error handling

**Features**:
- ✅ Converts `DioException` to app-specific exceptions (`ServerException`, `NetworkException`)
- ✅ Handles timeout errors
- ✅ Handles connection errors
- ✅ Extracts error messages from API responses
- ✅ Maps HTTP status codes to meaningful errors

**Status Code Mapping**:
| Code | Exception | Message |
|------|-----------|---------|
| 400 | `ServerException` | "Bad Request: {message}" |
| 401 | `ServerException` | "Unauthorized: {message}" |
| 403 | `ServerException` | "Forbidden: {message}" |
| 404 | `ServerException` | "Not Found: {message}" |
| 422 | `ServerException` | "Validation Error: {message}" |
| 500 | `ServerException` | "Internal Server Error: {message}" |
| Timeout | `NetworkException` | "Connection timeout" |
| No Internet | `NetworkException` | "No internet connection" |

### 3. **LoggingInterceptor** 📝
**Purpose**: Request/Response logging

**Features**:
- ✅ Logs all HTTP requests (method, URL, headers, body)
- ✅ Logs all HTTP responses (status, data)
- ✅ Logs errors
- ✅ **Only runs in debug mode** (won't log in production)

**Example Output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📤 REQUEST: POST https://api.example.com/auth/login
Headers: {Authorization: Bearer xxx, Content-Type: application/json}
Body: {email: test@example.com, password: ******}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📥 RESPONSE: 200 https://api.example.com/auth/login
Data: {user: {...}, token: xxx}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Comparison: Before vs After

### Before (http + ApiClient)

```dart
class AuthRemoteDataSourceImpl {
  final ApiClient apiClient;
  
  Future<UserModel> login(...) async {
    final response = await apiClient.post('/auth/login', body: {...});
    return UserModel.fromJson(response['user']);
  }
}
```

**Limitations**:
- ❌ Manual interceptor pattern
- ❌ Limited error handling
- ❌ No built-in retry logic
- ❌ No file upload/download support
- ❌ Basic timeout handling

### After (Dio + Interceptors)

```dart
class AuthRemoteDataSourceImpl {
  final DioClient dioClient;
  
  Future<UserModel> login(...) async {
    try {
      final response = await dioClient.post('/auth/login', data: {...});
      final data = response.data as Map<String, dynamic>;
      
      // Token automatically stored by interceptor
      if (data['token'] != null) {
        dioClient.setToken(data['token']);
      }
      
      return UserModel.fromJson(data['user']);
    } catch (e) {
      if (e is Exception) rethrow;
      throw ServerException('Login failed');
    }
  }
}
```

**Advantages**:
- ✅ True Angular-style interceptors
- ✅ Advanced error handling
- ✅ Built-in retry logic (can be added)
- ✅ File upload/download support
- ✅ Advanced timeout handling
- ✅ Better logging
- ✅ Production-ready

## DioClient API

### Basic Requests

```dart
// GET
final response = await dioClient.get('/users');

// POST
final response = await dioClient.post('/users', data: {
  'name': 'John',
  'email': 'john@example.com',
});

// PUT
final response = await dioClient.put('/users/1', data: {...});

// PATCH
final response = await dioClient.patch('/users/1', data: {...});

// DELETE
final response = await dioClient.delete('/users/1');
```

### With Query Parameters

```dart
final response = await dioClient.get(
  '/users',
  queryParameters: {
    'page': 1,
    'limit': 10,
    'search': 'john',
  },
);
// Request: GET /users?page=1&limit=10&search=john
```

### File Upload

```dart
final formData = FormData.fromMap({
  'title': 'My Photo',
  'file': await MultipartFile.fromFile(
    '/path/to/photo.jpg',
    filename: 'photo.jpg',
  ),
});

final response = await dioClient.upload(
  '/upload',
  formData,
  onSendProgress: (sent, total) {
    print('Progress: ${(sent / total * 100).toStringAsFixed(0)}%');
  },
);
```

### File Download

```dart
await dioClient.download(
  '/files/document.pdf',
  '/path/to/save/document.pdf',
  onReceiveProgress: (received, total) {
    print('Downloaded: ${(received / total * 100).toStringAsFixed(0)}%');
  },
);
```

## Token Management Flow

```dart
// 1. User logs in
final response = await dioClient.post('/auth/login', data: {...});

// 2. Store token (in data source)
if (response.data['token'] != null) {
  dioClient.setToken(response.data['token']);
  await localDataSource.saveToken(response.data['token']);
}

// 3. All requests now authenticated
await dioClient.get('/profile');        // ✅ Token auto-injected
await dioClient.post('/posts', ...);    // ✅ Token auto-injected

// 4. Token expired (401 response)
// → ErrorInterceptor automatically clears token

// 5. User logs out
await dioClient.post('/auth/logout');
dioClient.clearToken();
await localDataSource.clearToken();
```

## Configuration

Update in `injection_container.dart`:

```dart
getIt.registerLazySingleton(
  () => DioClient(
    baseUrl: 'https://your-api.com',  // Your API URL
    connectTimeout: 30,                // Connection timeout (seconds)
    receiveTimeout: 30,                // Receive timeout (seconds)
  ),
);
```

## Adding Custom Interceptors

Want to add token refresh? Create a new interceptor:

```dart
// core/network/interceptors/token_refresh_interceptor.dart
class TokenRefreshInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Token expired - try to refresh
      try {
        final newToken = await refreshToken();
        
        // Retry original request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // Refresh failed - logout user
        return handler.next(err);
      }
    }
    super.onError(err, handler);
  }
}

// Add to DioClient
dio.interceptors.add(TokenRefreshInterceptor());
```

## Testing

Mock Dio in tests:

```dart
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';

class MockDio extends Mock implements Dio {}

test('should return UserModel on successful login', () async {
  // Arrange
  final mockDio = MockDio();
  final dataSource = AuthRemoteDataSourceImpl(
    dioClient: DioClient(dio: mockDio),
  );
  
  when(mockDio.post(any, data: anyNamed('data')))
      .thenAnswer((_) async => Response(
        data: {'user': {'id': '1', 'username': 'test'}},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));
  
  // Act
  final result = await dataSource.login(
    email: 'test@example.com',
    password: 'password',
  );
  
  // Assert
  expect(result.username, 'test');
});
```

## Benefits Summary

✅ **Production-Ready**: Industry-standard HTTP client  
✅ **Scalable**: Easy to add new interceptors  
✅ **Maintainable**: Clear separation of concerns  
✅ **Debuggable**: Excellent logging in debug mode  
✅ **Testable**: Easy to mock  
✅ **Feature-Rich**: File upload/download, retry logic, etc.  
✅ **Angular-like**: Familiar pattern for web developers  

Your app is now ready to scale! 🚀
