import 'package:dartz/dartz.dart';
import 'package:flutter_application_4/core/errors/exceptions.dart';
import 'package:flutter_application_4/core/errors/failures.dart';
import 'package:flutter_application_4/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_application_4/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_application_4/features/auth/domain/entities/user.dart';
import 'package:flutter_application_4/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, User>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Call remote data source
      final userModel = await remoteDataSource.register(
        username: username,
        email: email,
        password: password,
      );

      // Cache user locally
      await localDataSource.cacheUser(userModel);

      // Return entity
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      // Registration succeeded but caching failed - still return success
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Call remote data source
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // Cache user locally
      await localDataSource.cacheUser(userModel);

      // Return entity
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Call remote logout
      await remoteDataSource.logout();

      // Clear local cache
      await localDataSource.clearCache();

      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getCachedUser();
      return Right(userModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Failed to get current user'));
    }
  }
}
