part of 'auth_bloc.dart';

sealed class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

// Formz-specific state for registration form
class RegisterFormState extends AuthState {
  final Username username;
  final Email email;
  final Password password;
  final FormzSubmissionStatus status;
  final bool isEmailValidating;
  final String? errorMessage;
  final bool hasSubmittedOnce; // Track if user has attempted submission

  const RegisterFormState({
    this.username = const Username.pure(),
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzSubmissionStatus.initial,
    this.isEmailValidating = false,
    this.errorMessage,
    this.hasSubmittedOnce = false,
  });

  @override
  List<Object> get props => [
        username,
        email,
        password,
        status,
        isEmailValidating,
        hasSubmittedOnce,
      ];

  RegisterFormState copyWith({
    Username? username,
    Email? email,
    Password? password,
    FormzSubmissionStatus? status,
    bool? isEmailValidating,
    String? errorMessage,
    bool? hasSubmittedOnce,
  }) {
    return RegisterFormState(
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      isEmailValidating: isEmailValidating ?? this.isEmailValidating,
      errorMessage: errorMessage ?? this.errorMessage,
      hasSubmittedOnce: hasSubmittedOnce ?? this.hasSubmittedOnce,
    );
  }

  /// Check if form is valid (all inputs valid + email not validating)
  /// Only enable submit when all fields are dirty AND valid
  bool get isFormValid {
    // All fields must be dirty (touched by user)
    if (username.isPure || email.isPure || password.isPure) {
      return false; // Button disabled until user fills all fields
    }
    
    // All fields touched - now validate them
    return Formz.validate([username, email, password]) && !isEmailValidating;
  }
}
