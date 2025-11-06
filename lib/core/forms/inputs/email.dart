import 'package:formz/formz.dart';
import 'package:flutter_application_4/core/utils/validation_rules.dart';

/// Email validation errors
enum EmailValidationError {
  empty,
  invalid,
  alreadyExists, // For async validation
}

/// Email input using Formz
/// Delegates validation logic to ValidationRules for consistency
class Email extends FormzInput<String, EmailValidationError> {
  /// Pure (untouched) constructor
  const Email.pure() : super.pure('');
  
  /// Dirty (user has interacted) constructor
  const Email.dirty([super.value = '']) : super.dirty();

  @override
  EmailValidationError? validator(String value) {
    // Use ValidationRules as single source of truth
    final errorMessage = ValidationRules.validateEmail(value);
    
    if (errorMessage == null) {
      return null; // Valid (async check happens separately)
    }
    
    // Map string error to enum
    if (value.isEmpty) {
      return EmailValidationError.empty;
    }
    
    // Must be invalid format
    return EmailValidationError.invalid;
  }

  /// Get error message for UI - delegates to ValidationRules
  String? get errorMessage {
    if (isValid || isPure) return null;
    
    // Use ValidationRules for consistent error messages
    if (error == EmailValidationError.alreadyExists) {
      return 'This email is already registered';
    }
    
    return ValidationRules.validateEmail(value);
  }
}
