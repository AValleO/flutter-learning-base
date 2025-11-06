# Auth Feature - Clean Architecture + DDD Implementation

## ✅ Complete Implementation

### Architecture Layers

```
lib/features/auth/
├── domain/                          # Business Logic (Pure Dart)
│   ├── entities/
│   │   └── user.dart               # Business entity
│   ├── repositories/
│   │   └── auth_repository.dart    # Repository interface
│   └── usecases/
│       ├── register_user.dart      # Registration use case
│       └── login_user.dart         # Login use case
│
├── data/                            # Data Layer (Infrastructure)
│   ├── models/
│   │   └── user_model.dart         # Data model (extends entity)
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart  # API calls
│   │   └── auth_local_data_source.dart   # Local cache
│   └── repositories/
│       └── auth_repository_impl.dart     # Repository implementation
│
└── presentation/                    # UI Layer
    ├── blocs/
    │   └── bloc/
    │       ├── auth_bloc.dart      # State management
    │       ├── auth_event.dart     # User actions
    │       └── auth_state.dart     # UI states
    ├── pages/
    │   └── register_page.dart      # Screen
    └── widgets/
        └── register_form.dart      # Form widget
```

## Data Flow

```
User Action (Button Click)
    ↓
Widget dispatches Event
    ↓
AuthBloc receives RegisterSubmitted event
    ↓
BLoC calls RegisterUser UseCase
    ↓
UseCase validates business rules
    ↓
UseCase calls AuthRepository (interface)
    ↓
AuthRepositoryImpl calls RemoteDataSource
    ↓
API Request → Response
    ↓
UserModel created from JSON
    ↓
Cached in LocalDataSource
    ↓
Converted to User Entity
    ↓
Wrapped in Either<Failure, User>
    ↓
BLoC emits new AuthState
    ↓
Widget rebuilds with new state
```

## Key Principles Applied

### 1. **Dependency Rule**
- Domain layer has NO dependencies on other layers
- Data and Presentation depend on Domain
- Dependencies point inward

### 2. **Separation of Concerns**
- **Entities**: Pure business objects
- **Use Cases**: Business rules and validation
- **Repository**: Abstract data access
- **BLoC**: UI state management
- **Data Sources**: External data (API, cache)

### 3. **Dependency Inversion**
- High-level modules (UseCases) don't depend on low-level modules (DataSources)
- Both depend on abstractions (Repository interface)

### 4. **Single Responsibility**
- Each class has one reason to change
- Use Cases are small and focused

## Usage Example

### In your widget:

```dart
// Dispatch event
context.read<AuthBloc>().add(
  RegisterSubmitted(
    username: 'john_doe',
    email: 'john@example.com',
    password: 'secure123',
  ),
);

// Listen to state changes
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    if (state is AuthAuthenticated) {
      return Text('Welcome ${state.user.username}!');
    }
    if (state is AuthError) {
      return Text('Error: ${state.message}');
    }
    return LoginForm();
  },
)
```

## Configuration Needed

### 1. Update API Base URL

In `lib/features/auth/data/datasources/auth_remote_data_source.dart`:
```dart
this.baseUrl = 'https://your-api.com', // Change this
```

### 2. Update API Response Structure

Adjust `UserModel.fromJson()` to match your API:
```dart
factory UserModel.fromJson(Map<String, dynamic> json) {
  return UserModel(
    id: json['id'],        // Match your API keys
    username: json['username'],
    email: json['email'],
    createdAt: DateTime.parse(json['created_at']),
  );
}
```

## Testing Structure

```
test/features/auth/
├── domain/
│   └── usecases/
│       └── register_user_test.dart
├── data/
│   ├── models/
│   │   └── user_model_test.dart
│   └── repositories/
│       └── auth_repository_impl_test.dart
└── presentation/
    └── blocs/
        └── auth_bloc_test.dart
```

## Benefits of This Architecture

✅ **Testable**: Each layer can be tested independently  
✅ **Maintainable**: Changes are localized  
✅ **Scalable**: Easy to add new features  
✅ **Clean**: Clear separation of concerns  
✅ **Flexible**: Easy to swap implementations  
✅ **Type-safe**: Compile-time error detection  

## Next Steps

1. ✅ Test with your actual API
2. ✅ Add navigation after successful registration
3. ✅ Implement login page using same BLoC
4. ✅ Add token management for authenticated requests
5. ✅ Write unit tests for each layer
6. ✅ Add error handling improvements
7. ✅ Implement logout functionality

## Dependencies Used

- `flutter_bloc`: State management
- `dartz`: Functional programming (Either)
- `equatable`: Value equality
- `get_it`: Dependency injection
- `http`: HTTP client
- `shared_preferences`: Local storage
