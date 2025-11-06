import 'package:formz/formz.dart';
import 'package:flutter_application_4/core/utils/validation_rules.dart';

/// Password validation errors
enum PasswordValidationError {
  empty,
  tooShort,
  tooLong,
  containsUsername, // Dependent validation
}

/// Password input using Formz with dependent validation
/// Delegates basic validation to ValidationRules for consistency
class Password extends FormzInput<String, PasswordValidationError> {
  final String username; // Dependency
  
  /// Pure (untouched) constructor
  const Password.pure({this.username = ''}) : super.pure('');
  
  /// Dirty (user has interacted) constructor
  const Password.dirty({
    String value = '',
    this.username = '',
  }) : super.dirty(value);

  @override
  PasswordValidationError? validator(String value) {
    // First check basic validation using ValidationRules
    final basicError = ValidationRules.validatePassword(value);
    
    if (basicError != null) {
      // Map string error to enum
      if (value.isEmpty) {
        return PasswordValidationError.empty;
      }
      
      if (value.length < ValidationRules.passwordMinLength) {
        return PasswordValidationError.tooShort;
      }
      
      if (value.length > ValidationRules.passwordMaxLength) {
        return PasswordValidationError.tooLong;
      }
    }
    
    // DEPENDENT VALIDATION: Password cannot contain username
    // This is Formz-specific and doesn't exist in ValidationRules
    if (username.isNotEmpty && 
        value.toLowerCase().contains(username.toLowerCase())) {
      return PasswordValidationError.containsUsername;
    }
    
    return null; // Valid
  }

  /// Get error message for UI - delegates to ValidationRules when possible
  String? get errorMessage {
    if (isValid || isPure) return null;
    
    // Handle dependent validation error (not in ValidationRules)
    if (error == PasswordValidationError.containsUsername) {
      return 'Password cannot contain your username';
    }
    
    // Use ValidationRules for consistent basic error messages
    return ValidationRules.validatePassword(value);
  }

  /// Copy with new username (for dependent validation)
  Password copyWithUsername(String newUsername) {
    return Password.dirty(
      value: value,
      username: newUsername,
    );
  }
}
