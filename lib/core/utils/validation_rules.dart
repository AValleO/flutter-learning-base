/// Shared validation rules for the entire app
/// Use these in BOTH UI forms and Use Cases to ensure consistency
class ValidationRules {
  // Private constructor to prevent instantiation
  ValidationRules._();

  // Username rules
  static const int usernameMinLength = 3;
  static const int usernameMaxLength = 30;

  // Email rules
  static final RegExp emailRegex = RegExp(
    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  // Password rules
  static const int passwordMinLength = 6;
  static const int passwordMaxLength = 100;

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    if (value.length < usernameMinLength) {
      return 'Username must be at least $usernameMinLength characters';
    }

    if (value.length > usernameMaxLength) {
      return 'Username must not exceed $usernameMaxLength characters';
    }

    // Only alphanumeric and underscores
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null; // Valid
  }

  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null; // Valid
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < passwordMinLength) {
      return 'Password must be at least $passwordMinLength characters';
    }

    if (value.length > passwordMaxLength) {
      return 'Password must not exceed $passwordMaxLength characters';
    }

    // Optional: Add complexity rules
    // if (!value.contains(RegExp(r'[A-Z]'))) {
    //   return 'Password must contain at least one uppercase letter';
    // }

    return null; // Valid
  }

  /// Check if username is valid (boolean)
  static bool isUsernameValid(String? value) {
    return validateUsername(value) == null;
  }

  /// Check if email is valid (boolean)
  static bool isEmailValid(String? value) {
    return validateEmail(value) == null;
  }

  /// Check if password is valid (boolean)
  static bool isPasswordValid(String? value) {
    return validatePassword(value) == null;
  }
}
