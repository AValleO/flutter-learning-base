part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Formz-based events for real-time validation
class RegisterUsernameChanged extends AuthEvent {
  final String username;

  const RegisterUsernameChanged(this.username);

  @override
  List<Object> get props => [username];
}

class RegisterEmailChanged extends AuthEvent {
  final String email;

  const RegisterEmailChanged(this.email);

  @override
  List<Object> get props => [email];
}

class RegisterPasswordChanged extends AuthEvent {
  final String password;

  const RegisterPasswordChanged(this.password);

  @override
  List<Object> get props => [password];
}

class RegisterEmailValidationRequested extends AuthEvent {
  const RegisterEmailValidationRequested();
}

class RegisterSubmitted extends AuthEvent {
  const RegisterSubmitted();
}

// Legacy events (keep for compatibility)
class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}
