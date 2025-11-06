import 'package:dartz/dartz.dart';
import 'package:flutter_application_4/core/errors/failures.dart';
import 'package:flutter_application_4/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();
}
