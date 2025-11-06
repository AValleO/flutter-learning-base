# Validation Strategy - Two Layers Done Right ✅

## The Problem You Identified

Having validation in both UI and Use Cases can lead to:
- ❌ Code duplication
- ❌ Inconsistent rules
- ❌ Maintenance nightmare
- ❌ Out-of-sync validations

## The Solution: Shared Validation Rules

Created `ValidationRules` class with **single source of truth** for all validation logic.

## Architecture

```
┌─────────────────────────────────────────────┐
│     Presentation Layer (UI)                 │
│  ┌─────────────────────────────────────┐   │
│  │  RegisterForm                       │   │
│  │  validator: ValidationRules.        │   │
│  │             validateUsername        │   │
│  └─────────────────────────────────────┘   │
└─────────────────┬───────────────────────────┘
                  │ uses same rules
                  ▼
┌─────────────────────────────────────────────┐
│      Core - Validation Rules                │
│  ┌─────────────────────────────────────┐   │
│  │  ValidationRules (Shared)           │   │
│  │  - validateUsername()               │   │
│  │  - validateEmail()                  │   │
│  │  - validatePassword()               │   │
│  └─────────────────────────────────────┘   │
└─────────────────┬───────────────────────────┘
                  │ uses same rules
                  ▼
┌─────────────────────────────────────────────┐
│     Domain Layer (Use Cases)                │
│  ┌─────────────────────────────────────┐   │
│  │  RegisterUser                       │   │
│  │  ValidationRules.validateUsername() │   │
│  └─────────────────────────────────────┘   │
└─────────────────────────────────────────────┘
```

## Two Layers, Different Purposes

### Layer 1: UI Validation (Immediate Feedback)
**When**: As user types  
**Why**: Better UX, instant feedback  
**What**: Client-side only

```dart
// register_form.dart
CustomTextFormField(
  validator: ValidationRules.validateUsername, // ← Shared rules
)
```

**Benefits**:
- ✅ No network call needed
- ✅ User gets instant feedback
- ✅ Prevents unnecessary API calls
- ✅ Better user experience

### Layer 2: Use Case Validation (Security)
**When**: Before calling API  
**Why**: Enforce business rules, can't be bypassed  
**What**: Server-side logic

```dart
// register_user.dart
final usernameError = ValidationRules.validateUsername(params.username);
if (usernameError != null) {
  return Left(ValidationFailure(usernameError)); // ← Shared rules
}
```

**Benefits**:
- ✅ Security (client can't bypass)
- ✅ Works for ALL clients (mobile, web, API direct access)
- ✅ Business logic stays in domain layer
- ✅ Single source of truth

## Why Both Layers?

### ❌ **Only UI Validation**
```dart
// User can bypass by:
// - Disabling JavaScript
// - Using API directly
// - Modifying app code
```

### ❌ **Only Use Case Validation**
```dart
// Bad UX:
// - User types invalid email
// - Clicks submit
// - Waits for network call
// - Gets error back
// - Frustrating experience
```

### ✅ **Both Layers (Correct!)**
```dart
// UI: Instant feedback while typing
// Use Case: Security enforcement
// Result: Best UX + Security
```

## ValidationRules API

### Constants
```dart
ValidationRules.usernameMinLength    // 3
ValidationRules.usernameMaxLength    // 30
ValidationRules.passwordMinLength    // 6
ValidationRules.passwordMaxLength    // 100
ValidationRules.emailRegex           // RegExp(...)
```

### String Validators (for UI forms)
```dart
// Returns error message or null
ValidationRules.validateUsername(value)  // String?
ValidationRules.validateEmail(value)     // String?
ValidationRules.validatePassword(value)  // String?

// Example
validator: ValidationRules.validateUsername
```

### Boolean Validators (for logic checks)
```dart
// Returns true/false
ValidationRules.isUsernameValid(value)   // bool
ValidationRules.isEmailValid(value)      // bool
ValidationRules.isPasswordValid(value)   // bool

// Example
if (ValidationRules.isEmailValid(email)) {
  // proceed
}
```

## Usage Examples

### In UI Form
```dart
TextFormField(
  validator: ValidationRules.validateEmail,
  // Returns: "Email is required" or "Please enter a valid email"
)
```

### In Use Case
```dart
final emailError = ValidationRules.validateEmail(params.email);
if (emailError != null) {
  return Left(ValidationFailure(emailError));
}
```

### In Business Logic
```dart
if (!ValidationRules.isPasswordValid(newPassword)) {
  throw Exception('Invalid password');
}
```

## Maintaining Validation Rules

### ✅ **To Add New Rule**:

1. Update `ValidationRules` class:
```dart
static String? validatePhone(String? value) {
  if (value == null || value.isEmpty) {
    return 'Phone is required';
  }
  // Add logic
  return null;
}
```

2. Use in UI:
```dart
validator: ValidationRules.validatePhone
```

3. Use in Use Case:
```dart
final phoneError = ValidationRules.validatePhone(params.phone);
if (phoneError != null) {
  return Left(ValidationFailure(phoneError));
}
```

**Result**: Changes once, works everywhere! ✅

### ✅ **To Modify Rule**:

Example: Change password min length from 6 to 8

1. Update `ValidationRules`:
```dart
static const int passwordMinLength = 8; // Changed from 6
```

2. That's it! Both UI and Use Case automatically updated ✅

## Real-World Example

### Before (Duplicated) ❌
```dart
// UI - register_form.dart
validator: (value) {
  if (value == null || value.length < 6) {
    return 'Password must be at least 6 characters';
  }
  return null;
}

// Use Case - register_user.dart
if (params.password.length < 6) {
  return Left(ValidationFailure('Password must be at least 6 characters'));
}

// Problem: Change one, must remember to change the other!
```

### After (Shared) ✅
```dart
// UI - register_form.dart
validator: ValidationRules.validatePassword

// Use Case - register_user.dart  
final passwordError = ValidationRules.validatePassword(params.password);
if (passwordError != null) {
  return Left(ValidationFailure(passwordError));
}

// Solution: Change once in ValidationRules, both update automatically!
```

## Benefits Summary

✅ **Single Source of Truth**: All validation logic in one place  
✅ **DRY Principle**: Don't Repeat Yourself  
✅ **Easy Maintenance**: Change once, update everywhere  
✅ **Type Safe**: Compile-time checking  
✅ **Testable**: Easy to unit test validators  
✅ **Consistent**: Same rules across UI and business logic  
✅ **Scalable**: Easy to add new validations  

## Testing Validation Rules

```dart
// test/core/utils/validation_rules_test.dart
void main() {
  group('ValidationRules', () {
    group('validateUsername', () {
      test('returns error when empty', () {
        expect(
          ValidationRules.validateUsername(''),
          'Username is required',
        );
      });

      test('returns error when too short', () {
        expect(
          ValidationRules.validateUsername('ab'),
          'Username must be at least 3 characters',
        );
      });

      test('returns null when valid', () {
        expect(
          ValidationRules.validateUsername('john_doe'),
          null,
        );
      });
    });
  });
}
```

## Best Practices

1. ✅ **Always use ValidationRules** in both UI and Use Cases
2. ✅ **Never hardcode validation logic** directly
3. ✅ **Keep rules simple and focused**
4. ✅ **Add unit tests** for all validation rules
5. ✅ **Use constants** for magic numbers (min/max lengths)
6. ✅ **Document complex rules** with comments

Your validation is now **synchronized, maintainable, and production-ready**! 🎉
