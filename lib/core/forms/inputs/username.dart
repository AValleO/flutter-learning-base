import 'package:formz/formz.dart';
import 'package:flutter_application_4/core/utils/validation_rules.dart';

/// Username validation errors
enum UsernameValidationError {
  empty,
  tooShort,
  tooLong,
  invalidCharacters,
}

/// Username input using Formz
/// Delegates validation logic to ValidationRules for consistency
class Username extends FormzInput<String, UsernameValidationError> {
  /// Pure (untouched) constructor
  const Username.pure() : super.pure('');
  
  /// Dirty (user has interacted) constructor
  const Username.dirty([super.value = '']) : super.dirty();

  @override
  UsernameValidationError? validator(String value) {
    // Use ValidationRules as single source of truth
    final errorMessage = ValidationRules.validateUsername(value);
    
    if (errorMessage == null) {
      return null; // Valid
    }
    
    // Map string error to enum based on the error message
    if (value.isEmpty) {
      return UsernameValidationError.empty;
    }
    
    if (value.length < ValidationRules.usernameMinLength) {
      return UsernameValidationError.tooShort;
    }
    
    if (value.length > ValidationRules.usernameMaxLength) {
      return UsernameValidationError.tooLong;
    }
    
    // Must be invalid characters
    return UsernameValidationError.invalidCharacters;
  }

  /// Get error message for UI - delegates to ValidationRules
  String? get errorMessage {
    if (isValid || isPure) return null;
    
    // Use ValidationRules for consistent error messages
    return ValidationRules.validateUsername(value);
  }
}
