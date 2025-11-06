# Formz Integration Guide

## Overview

This guide explains the implementation of the **formz** package in the Flutter authentication feature, demonstrating advanced form validation patterns including:

1. **Dependent Validation**: Password validation that depends on username value
2. **Async Validation**: Email validation against company API
3. **Real-time Validation**: Field validation as user types
4. **Form Status Tracking**: Automatic form validity monitoring

---

## Why Formz?

### When to Use Formz
- ✅ Complex forms with multiple interdependent fields
- ✅ Async validation requirements (API checks)
- ✅ Team standardization on validation patterns
- ✅ Strong type safety for form inputs
- ✅ Centralized validation logic

### When NOT to Use Formz
- ❌ Simple forms with 1-3 independent fields
- ❌ Prototypes or quick MVPs
- ❌ Forms with only basic validation (required, length)

---

## Architecture

### Input Models

Each form field has a corresponding `FormzInput` subclass:

```
lib/core/forms/inputs/
├── username.dart      # Username validation
├── email.dart         # Email format + async availability
└── password.dart      # Password with username dependency
```

#### Username Input
```dart
class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure() : super.pure('');
  const Username.dirty([super.value = '']) : super.dirty();

  @override
  UsernameValidationError? validator(String value) {
    if (value.isEmpty) return UsernameValidationError.empty;
    if (value.length < 3) return UsernameValidationError.tooShort;
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return UsernameValidationError.invalidCharacters;
    }
    return null;
  }
}
```

**States:**
- `pure`: User hasn't interacted with field
- `dirty`: User has typed something
- `valid`: Passes all validation rules
- `invalid`: Has validation errors

#### Password Input (Dependent Validation)
```dart
class Password extends FormzInput<String, PasswordValidationError> {
  final String username; // DEPENDENCY

  const Password.dirty({
    String value = '',
    this.username = '',
  }) : super.dirty(value);

  @override
  PasswordValidationError? validator(String value) {
    // ... other validations ...
    
    // DEPENDENT VALIDATION
    if (username.isNotEmpty && 
        value.toLowerCase().contains(username.toLowerCase())) {
      return PasswordValidationError.containsUsername;
    }
    return null;
  }
}
```

**Key Feature:** Password validation re-runs automatically when username changes.

---

## BLoC Integration

### Events

```dart
// Real-time field changes
class RegisterUsernameChanged extends AuthEvent {
  final String username;
  const RegisterUsernameChanged(this.username);
}

class RegisterEmailChanged extends AuthEvent {
  final String email;
  const RegisterEmailChanged(this.email);
}

class RegisterPasswordChanged extends AuthEvent {
  final String password;
  const RegisterPasswordChanged(this.password);
}

// Async email validation
class RegisterEmailValidationRequested extends AuthEvent {}

// Form submission
class RegisterSubmitted extends AuthEvent {}
```

### State

```dart
class RegisterFormState extends AuthState {
  final Username username;
  final Email email;
  final Password password;
  final FormzSubmissionStatus status;  // initial, inProgress, success, failure
  final bool isEmailValidating;        // Async validation indicator
  final String? errorMessage;

  bool get isFormValid =>
      Formz.validate([username, email, password]) && !isEmailValidating;
}
```

**FormzSubmissionStatus:**
- `initial`: Form ready for input
- `inProgress`: Submitting to API
- `success`: Submission successful
- `failure`: Submission failed

### Event Handlers

#### 1. Username Changed (with Password Re-validation)
```dart
on<RegisterUsernameChanged>((event, emit) {
  final username = Username.dirty(event.username);
  
  // Update password validation with new username
  final password = currentState.password.copyWithUsername(event.username);
  
  emit(currentState.copyWith(
    username: username,
    password: password, // Password now re-validates
  ));
});
```

#### 2. Email Changed (with Async Validation Trigger)
```dart
on<RegisterEmailChanged>((event, emit) {
  final email = Email.dirty(event.email);
  
  emit(currentState.copyWith(email: email));
});

on<RegisterEmailValidationRequested>((event, emit) async {
  emit(currentState.copyWith(isEmailValidating: true));
  
  final isAvailable = await emailValidationService.validateEmailDebounced(
    currentState.email.value,
  );
  
  emit(currentState.copyWith(
    isEmailValidating: false,
    errorMessage: isAvailable ? null : 'Email already registered',
  ));
});
```

#### 3. Password Changed (with Username Dependency)
```dart
on<RegisterPasswordChanged>((event, emit) {
  final password = Password.dirty(
    value: event.password,
    username: currentState.username.value, // Inject dependency
  );
  
  emit(currentState.copyWith(password: password));
});
```

#### 4. Form Submission
```dart
on<RegisterSubmitted>((event, emit) async {
  // Mark all fields as dirty to show validation errors
  final username = Username.dirty(currentState.username.value);
  final email = Email.dirty(currentState.email.value);
  final password = Password.dirty(
    value: currentState.password.value,
    username: currentState.username.value,
  );
  
  emit(currentState.copyWith(
    username: username,
    email: email,
    password: password,
  ));
  
  // Validate before submission
  if (!Formz.validate([username, email, password])) {
    emit(currentState.copyWith(
      status: FormzSubmissionStatus.failure,
      errorMessage: 'Please fix errors before submitting',
    ));
    return;
  }
  
  emit(currentState.copyWith(status: FormzSubmissionStatus.inProgress));
  
  // Submit to API...
});
```

---

## UI Implementation

### Field Components

#### Username Field
```dart
class _UsernameField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          current is RegisterFormState &&
          previous is RegisterFormState &&
          previous.username != current.username,
      builder: (context, state) {
        if (state is! RegisterFormState) return const SizedBox();

        return TextFormField(
          onChanged: (value) {
            context.read<AuthBloc>().add(RegisterUsernameChanged(value));
          },
          decoration: InputDecoration(
            labelText: 'Username',
            errorText: state.username.errorMessage, // From input model
          ),
        );
      },
    );
  }
}
```

#### Email Field (with Async Validation Indicator)
```dart
class _EmailField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! RegisterFormState) return const SizedBox();

        return TextFormField(
          onChanged: (value) {
            context.read<AuthBloc>().add(RegisterEmailChanged(value));
            
            // Trigger async validation when format is valid
            if (state.email.isValid) {
              context.read<AuthBloc>().add(RegisterEmailValidationRequested());
            }
          },
          decoration: InputDecoration(
            labelText: 'Email',
            suffixIcon: state.isEmailValidating
                ? CircularProgressIndicator() // Validating
                : state.email.isValid
                    ? Icon(Icons.check_circle, color: Colors.green) // Valid
                    : null,
            errorText: state.email.errorMessage,
          ),
        );
      },
    );
  }
}
```

#### Password Field (with Dependent Validation Feedback)
```dart
class _PasswordField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! RegisterFormState) return const SizedBox();

        return TextFormField(
          onChanged: (value) {
            context.read<AuthBloc>().add(RegisterPasswordChanged(value));
          },
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: state.password.errorMessage,
            helperText: 'Password cannot contain your username',
          ),
        );
      },
    );
  }
}
```

#### Submit Button (with Form Validity)
```dart
class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! RegisterFormState) return const SizedBox();

        final isLoading = state.status == FormzSubmissionStatus.inProgress;
        final isEnabled = state.isFormValid && !isLoading;

        return ElevatedButton(
          onPressed: isEnabled
              ? () => context.read<AuthBloc>().add(RegisterSubmitted())
              : null, // Disabled when invalid or loading
          child: isLoading
              ? CircularProgressIndicator()
              : Text('Register'),
        );
      },
    );
  }
}
```

---

## Async Email Validation

### Service Implementation
```dart
class EmailValidationService {
  final DioClient _client;

  Future<bool> checkEmailAvailability(String email) async {
    final response = await _client.get(
      '/auth/check-email',
      queryParameters: {'email': email},
    );
    return response.data['available'] as bool;
  }

  // Debounced to avoid excessive API calls
  Future<bool> validateEmailDebounced(
    String email, {
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    await Future.delayed(delay);
    return checkEmailAvailability(email);
  }
}
```

### Flow
1. User types email → `RegisterEmailChanged` event
2. BLoC validates format → If valid, triggers `RegisterEmailValidationRequested`
3. Service waits 500ms (debounce) → Calls API
4. UI shows loading spinner during validation
5. Result updates state → Shows error or checkmark

---

## Dependent Validation Pattern

### The Problem
Password validation needs to know the current username value to check if it's contained in the password.

### The Solution

**1. Password Input with Dependency:**
```dart
class Password extends FormzInput<String, PasswordValidationError> {
  final String username; // Inject dependency
  
  const Password.dirty({
    String value = '',
    this.username = '',
  }) : super.dirty(value);

  @override
  PasswordValidationError? validator(String value) {
    if (value.toLowerCase().contains(username.toLowerCase())) {
      return PasswordValidationError.containsUsername;
    }
    return null;
  }
}
```

**2. Update Password When Username Changes:**
```dart
on<RegisterUsernameChanged>((event, emit) {
  final username = Username.dirty(event.username);
  
  // Password re-validates with new username
  final password = currentState.password.copyWithUsername(event.username);
  
  emit(currentState.copyWith(
    username: username,
    password: password, // This triggers re-validation
  ));
});
```

**3. Visual Result:**
- User types username: "john"
- User types password: "john123"
- Error appears: "Password cannot contain your username"
- User changes username to "mike"
- Error disappears automatically (password no longer contains "mike")

---

## Form Validity Tracking

### Automatic Validation
```dart
bool get isFormValid =>
    Formz.validate([username, email, password]) && !isEmailValidating;
```

**Formz.validate()** returns `true` only if:
- All inputs are valid (no validation errors)
- All inputs are dirty OR form has been submitted

### Submit Button State
```dart
final isEnabled = state.isFormValid && !isLoading;

ElevatedButton(
  onPressed: isEnabled ? _submit : null, // null = disabled
  child: Text('Register'),
)
```

---

## Benefits of This Approach

### 1. Type Safety
```dart
// ✅ Type-safe
final username = state.username.value; // String guaranteed

// ❌ Prone to errors
final username = _usernameController.text; // Could be anything
```

### 2. Centralized Validation Logic
```dart
// Single source of truth
class Username extends FormzInput<...> {
  @override
  UsernameValidationError? validator(String value) {
    // All username validation in one place
  }
}
```

### 3. Reusable Input Models
```dart
// Use Username input in multiple forms
class RegisterFormState { final Username username; }
class ProfileFormState { final Username username; }
```

### 4. Testability
```dart
test('username validation', () {
  final username = Username.dirty('ab');
  expect(username.isValid, false);
  expect(username.error, UsernameValidationError.tooShort);
});
```

### 5. Clear Error Handling
```dart
enum UsernameValidationError {
  empty,
  tooShort,
  invalidCharacters,
}

String? get errorMessage {
  switch (error) {
    case UsernameValidationError.empty:
      return 'Username is required';
    // ...
  }
}
```

---

## Common Patterns

### Pattern 1: Field-Level Real-Time Validation
```dart
TextFormField(
  onChanged: (value) {
    context.read<AuthBloc>().add(FieldChanged(value));
  },
  decoration: InputDecoration(
    errorText: state.field.errorMessage, // Shows immediately
  ),
)
```

### Pattern 2: Submit-Time Full Validation
```dart
on<FormSubmitted>((event, emit) {
  // Mark all fields as dirty to show all errors
  final username = Username.dirty(currentState.username.value);
  final email = Email.dirty(currentState.email.value);
  
  emit(currentState.copyWith(username: username, email: email));
  
  if (!Formz.validate([username, email])) {
    return; // Don't submit if invalid
  }
  
  // Proceed with submission
});
```

### Pattern 3: Async Validation with Debounce
```dart
on<EmailChanged>((event, emit) {
  emit(currentState.copyWith(email: Email.dirty(event.email)));
  
  if (currentState.email.isValid) {
    add(AsyncValidationRequested()); // Trigger after debounce
  }
});
```

---

## Migration from Simple Forms

### Before (Simple TextFormField)
```dart
String _username = '';
String? _usernameError;

TextFormField(
  onChanged: (value) {
    setState(() {
      _username = value;
      _usernameError = ValidationRules.validateUsername(value);
    });
  },
  decoration: InputDecoration(errorText: _usernameError),
)
```

### After (Formz)
```dart
// In BLoC
on<UsernameChanged>((event, emit) {
  emit(currentState.copyWith(
    username: Username.dirty(event.username),
  ));
});

// In UI
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return TextFormField(
      onChanged: (value) {
        context.read<AuthBloc>().add(UsernameChanged(value));
      },
      decoration: InputDecoration(
        errorText: state.username.errorMessage,
      ),
    );
  },
)
```

**Trade-off:** More boilerplate, but better scalability and maintainability.

---

## Testing Strategy

### Unit Tests for Input Models
```dart
group('Username', () {
  test('pure username is valid', () {
    expect(Username.pure().isValid, true);
  });

  test('empty username is invalid', () {
    expect(Username.dirty('').isValid, false);
  });

  test('short username is invalid', () {
    expect(Username.dirty('ab').isValid, false);
  });

  test('valid username passes', () {
    expect(Username.dirty('john_doe').isValid, true);
  });
});
```

### BLoC Tests
```dart
blocTest<AuthBloc, AuthState>(
  'emits valid state when username is valid',
  build: () => AuthBloc(...),
  act: (bloc) => bloc.add(RegisterUsernameChanged('validuser')),
  expect: () => [
    isA<RegisterFormState>()
        .having((s) => s.username.isValid, 'isValid', true),
  ],
);
```

---

## Best Practices

1. **Always provide error messages:**
   ```dart
   String? get errorMessage {
     if (isValid || isPure) return null;
     // Map each error enum to user-friendly message
   }
   ```

2. **Use pure for initial state:**
   ```dart
   RegisterFormState(
     username: const Username.pure(), // Don't show errors initially
   )
   ```

3. **Mark as dirty on user interaction:**
   ```dart
   final username = Username.dirty(event.username);
   ```

4. **Debounce async validation:**
   ```dart
   Future.delayed(Duration(milliseconds: 500));
   ```

5. **Handle validation loading states:**
   ```dart
   suffixIcon: isValidating ? CircularProgressIndicator() : null
   ```

---

## Resources

- [Formz Package](https://pub.dev/packages/formz)
- [BLoC Library](https://bloclibrary.dev)
- [Clean Architecture Guide](./ARCHITECTURE.md)
- [Validation Strategy](./VALIDATION_STRATEGY.md)

---

## Summary

This implementation demonstrates **enterprise-level form validation** with:
- ✅ Type-safe input models
- ✅ Dependent validation (password checks username)
- ✅ Async validation (email API check)
- ✅ Real-time feedback
- ✅ Automatic form validity tracking
- ✅ Clear separation of concerns
- ✅ Highly testable code

Perfect for complex production applications where form validation is critical.
