import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';
import 'package:flutter_application_4/features/auth/domain/entities/user.dart';
import 'package:flutter_application_4/features/auth/domain/usecases/register_user.dart';
import 'package:flutter_application_4/features/auth/domain/usecases/login_user.dart';
import 'package:flutter_application_4/core/forms/inputs/username.dart';
import 'package:flutter_application_4/core/forms/inputs/email.dart';
import 'package:flutter_application_4/core/forms/inputs/password.dart';
import 'package:flutter_application_4/core/services/email_validation_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUser registerUserUseCase;
  final LoginUser loginUserUseCase;
  final EmailValidationService emailValidationService;

  AuthBloc({
    required this.registerUserUseCase,
    required this.loginUserUseCase,
    required this.emailValidationService,
  }) : super(const RegisterFormState()) {
    
    // Handle username changes with dependent password validation
    on<RegisterUsernameChanged>((event, emit) {
      if (state is! RegisterFormState) return;
      final currentState = state as RegisterFormState;
      
      final username = Username.dirty(event.username);
      
      // Update password validation with new username (dependent validation)
      final password = !currentState.password.isPure 
          ? currentState.password.copyWithUsername(event.username) 
          : currentState.password;
      
      emit(currentState.copyWith(
        username: username,
        password: password,
        status: FormzSubmissionStatus.initial,
      ));
    });

    // Handle email changes
    on<RegisterEmailChanged>((event, emit) {
      if (state is! RegisterFormState) return;
      final currentState = state as RegisterFormState;
      
      final email = Email.dirty(event.email);
      
      emit(currentState.copyWith(
        email: email,
        status: FormzSubmissionStatus.initial,
      ));
    });

    // Handle password changes with username dependency
    on<RegisterPasswordChanged>((event, emit) {
      if (state is! RegisterFormState) return;
      final currentState = state as RegisterFormState;
      
      final password = Password.dirty(
        value: event.password,
        username: currentState.username.value,
      );
      
      emit(currentState.copyWith(
        password: password,
        status: FormzSubmissionStatus.initial,
      ));
    });

    // Handle async email validation
    on<RegisterEmailValidationRequested>((event, emit) async {
      if (state is! RegisterFormState) return;
      final currentState = state as RegisterFormState;
      
      // Only validate if email format is valid
      if (!currentState.email.isValid) return;
      
      emit(currentState.copyWith(isEmailValidating: true));
      
      try {
        final isAvailable = await emailValidationService.validateEmailDebounced(
          currentState.email.value,
        );
        
        if (!isAvailable) {
          // Email already exists
          emit(currentState.copyWith(
            email: Email.dirty(currentState.email.value),
            isEmailValidating: false,
            errorMessage: 'This email is already registered',
          ));
        } else {
          // Email is available
          emit(currentState.copyWith(
            isEmailValidating: false,
            errorMessage: null,
          ));
        }
      } catch (e) {
        // Error during validation, allow submission
        emit(currentState.copyWith(
          isEmailValidating: false,
          errorMessage: null,
        ));
      }
    });

    // Handle form submission with formz
    on<RegisterSubmitted>((event, emit) async {
      if (state is! RegisterFormState) return;
      final currentState = state as RegisterFormState;
      
      // Mark that user has attempted submission
      // This enables real-time validation feedback
      emit(currentState.copyWith(hasSubmittedOnce: true));
      
      // Validate all inputs are dirty (user has touched them)
      final username = Username.dirty(currentState.username.value);
      final email = Email.dirty(currentState.email.value);
      final password = Password.dirty(
        value: currentState.password.value,
        username: currentState.username.value,
      );
      
      emit(currentState.copyWith(
        username: username,
        email: email,
        password: password,
        status: FormzSubmissionStatus.initial,
        hasSubmittedOnce: true,
      ));
      
      // Check if form is valid
      if (!Formz.validate([username, email, password])) {
        emit(currentState.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: 'Please fix the errors before submitting',
          hasSubmittedOnce: true,
        ));
        return;
      }
      
      emit(currentState.copyWith(
        status: FormzSubmissionStatus.inProgress,
        hasSubmittedOnce: true,
      ));

      final result = await registerUserUseCase(
        RegisterParams(
          username: username.value,
          email: email.value,
          password: password.value,
        ),
      );

      result.fold(
        (failure) => emit(currentState.copyWith(
          status: FormzSubmissionStatus.failure,
          errorMessage: failure.message,
          hasSubmittedOnce: true,
        )),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    // Handle Login (legacy)
    on<LoginSubmitted>((event, emit) async {
      emit(const AuthLoading());

      final result = await loginUserUseCase(
        LoginParams(
          email: event.email,
          password: event.password,
        ),
      );

      result.fold(
        (failure) => emit(AuthError(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    // Handle Logout
    on<LogoutRequested>((event, emit) {
      emit(const AuthUnauthenticated());
    });

    // Check Auth Status
    on<CheckAuthStatus>((event, emit) {
      // TODO: Implement checking cached user
      emit(const AuthUnauthenticated());
    });
  }
}
