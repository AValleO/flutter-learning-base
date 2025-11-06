# Unified Validation Architecture

## Problem Solved ✅

Previously, we had **duplicate validation logic** in two places:

1. **`ValidationRules`** class (used by Use Cases in Domain layer)
2. **Formz Input Models** (used by UI in Presentation layer)

This created a maintenance risk: changing validation rules required updating both locations.

## Solution: Single Source of Truth

Now **all Formz inputs delegate to `ValidationRules`** for their validation logic:

```dart
// Before (Duplicated Logic)
class Username extends FormzInput<String, UsernameValidationError> {
  @override
  UsernameValidationError? validator(String value) {
    if (value.length < 3) {  // ❌ Hardcoded rule
      return UsernameValidationError.tooShort;
    }
    // ...
  }
}

// After (Unified)
class Username extends FormzInput<String, UsernameValidationError> {
  @override
  UsernameValidationError? validator(String value) {
    final errorMessage = ValidationRules.validateUsername(value);
    
    if (errorMessage == null) return null; // Valid
    
    // Map ValidationRules result to enum
    if (value.length < ValidationRules.usernameMinLength) {
      return UsernameValidationError.tooShort;
    }
    // ...
  }
  
  String? get errorMessage {
    if (isValid || isPure) return null;
    return ValidationRules.validateUsername(value); // ✅ Delegate
  }
}
```

## Architecture Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    ValidationRules                          │
│            (Single Source of Truth)                         │
│  - usernameMinLength = 3                                    │
│  - validateUsername(String) -> String?                      │
│  - validateEmail(String) -> String?                         │
│  - validatePassword(String) -> String?                      │
└────────────────┬────────────────────────────┬───────────────┘
                 │                            │
        Used by  │                            │  Used by
                 ▼                            ▼
    ┌────────────────────────┐   ┌───────────────────────┐
    │   Use Cases            │   │   Formz Inputs        │
    │   (Domain Layer)       │   │   (Presentation)      │
    ├────────────────────────┤   ├───────────────────────┤
    │ RegisterUser:          │   │ Username.validator(): │
    │   ValidationRules      │   │   ValidationRules     │
    │   .validateUsername()  │   │   .validateUsername() │
    └────────────────────────┘   └───────────────────────┘
```

## Benefits

### 1. **Single Place to Change Rules**
```dart
// Change validation in ONE place:
class ValidationRules {
  static const int usernameMinLength = 5; // Changed from 3
}

// Both Use Cases AND UI automatically use new rule ✅
```

### 2. **Consistent Error Messages**
```dart
// UI uses same messages as Domain layer
String? get errorMessage {
  return ValidationRules.validateUsername(value); // Same message
}
```

### 3. **Easy Testing**
```dart
test('UI and Use Case have same validation', () {
  const invalidUsername = 'ab';
  
  // Use Case validation
  final useCaseError = ValidationRules.validateUsername(invalidUsername);
  
  // UI validation
  final uiInput = Username.dirty(invalidUsername);
  
  // Both should fail for same reason
  expect(useCaseError, isNotNull);
  expect(uiInput.isValid, false);
  expect(uiInput.errorMessage, equals(useCaseError));
});
```

## Special Cases

### Dependent Validation (Password + Username)

The **dependent validation** (password cannot contain username) is **Formz-specific** and doesn't exist in `ValidationRules` because:

1. `ValidationRules` validates **individual fields** in isolation
2. Dependent validation requires **cross-field knowledge**
3. This is a **UI-layer concern** (real-time feedback)

```dart
class Password extends FormzInput<String, PasswordValidationError> {
  final String username; // Dependency
  
  @override
  PasswordValidationError? validator(String value) {
    // Basic validation from ValidationRules
    final basicError = ValidationRules.validatePassword(value);
    if (basicError != null) {
      // Map to enum...
    }
    
    // Formz-specific dependent validation
    if (username.isNotEmpty && 
        value.toLowerCase().contains(username.toLowerCase())) {
      return PasswordValidationError.containsUsername;
    }
    
    return null;
  }
}
```

### Async Validation (Email Availability)

The **async email check** is handled by:

1. `ValidationRules.validateEmail()` - Format validation (synchronous)
2. `EmailValidationService` - API check (asynchronous)
3. `RegisterEmailValidationRequested` event - Triggers async check

```dart
// Format validation (immediate)
final email = Email.dirty('user@example.com');
email.isValid; // true if format correct

// Availability validation (async, triggered separately)
context.read<AuthBloc>().add(RegisterEmailValidationRequested());
```

## Updated Files

All three Formz inputs now delegate to `ValidationRules`:

1. ✅ `lib/core/forms/inputs/username.dart`
2. ✅ `lib/core/forms/inputs/email.dart`
3. ✅ `lib/core/forms/inputs/password.dart`

## Migration Path

### Old Form (register_form.dart)
Uses `RegisterSubmitted(username, email, password)` event - **deprecated**

### New Form (register_form_with_formz.dart)
Uses formz inputs with unified validation - **recommended**

To migrate your app:

```dart
// In your registration page
BlocProvider(
  create: (context) => getIt<AuthBloc>(),
  child: RegisterFormWithFormz(), // Use new form
)
```

## Verification

Run this to confirm no duplication:

```bash
# All validation constants are in ValidationRules
grep -r "minLength\|maxLength" lib/core/forms/inputs/
# Should find references to ValidationRules, not hardcoded values

# All error messages come from ValidationRules
grep -r "must be at least" lib/core/forms/inputs/
# Should find: ValidationRules.validateUsername(value)
# Not find: 'Username must be at least...'
```

## Summary

✅ **One source of truth**: `ValidationRules` class  
✅ **Formz inputs delegate**: Call `ValidationRules` methods  
✅ **Consistent everywhere**: UI and Domain use same logic  
✅ **Easy maintenance**: Change rules in one place  
✅ **Special cases handled**: Dependent and async validation where needed  

Your validation is now fully unified! 🎉
