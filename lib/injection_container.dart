import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_4/core/network/dio_client.dart';
import 'package:flutter_application_4/core/services/email_validation_service.dart';
import 'package:flutter_application_4/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:flutter_application_4/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:flutter_application_4/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_application_4/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_application_4/features/auth/domain/usecases/login_user.dart';
import 'package:flutter_application_4/features/auth/domain/usecases/register_user.dart';
import 'package:flutter_application_4/features/auth/presentation/blocs/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // BLoC
  getIt.registerFactory(
    () => AuthBloc(
      registerUserUseCase: getIt(),
      loginUserUseCase: getIt(),
      emailValidationService: getIt(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(() => RegisterUser(getIt()));
  getIt.registerLazySingleton(() => LoginUser(getIt()));

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dioClient: getIt(),
    ),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: getIt(),
    ),
  );

  //! Core - Services
  getIt.registerLazySingleton(
    () => EmailValidationService(getIt()),
  );

  //! Core - Network (Dio with Interceptors)
  getIt.registerLazySingleton(
    () => DioClient(
      baseUrl: 'https://api.example.com', // Replace with your API
      connectTimeout: 30,
      receiveTimeout: 30,
    ),
  );

  //! Core - External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
}
