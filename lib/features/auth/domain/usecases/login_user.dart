import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_application_4/core/errors/failures.dart';
import 'package:flutter_application_4/core/utils/validation_rules.dart';
import 'package:flutter_application_4/features/auth/domain/entities/user.dart';
import 'package:flutter_application_4/features/auth/domain/repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    // Business validations using shared rules
    final emailError = ValidationRules.validateEmail(params.email);
    if (emailError != null) {
      return Left(ValidationFailure(emailError));
    }

    final passwordError = ValidationRules.validatePassword(params.password);
    if (passwordError != null) {
      return Left(ValidationFailure(passwordError));
    }

    // All validations passed - delegate to repository
    return await repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
