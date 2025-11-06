import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:flutter_application_4/features/auth/presentation/blocs/bloc/auth_bloc.dart';
import 'package:flutter_application_4/core/forms/inputs/password.dart';

class RegisterFormWithFormz extends StatelessWidget {
  const RegisterFormWithFormz({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome, ${state.user.username}!'),
              backgroundColor: Colors.green,
            ),
          );
          // TODO: Navigate to home page
        } else if (state is RegisterFormState) {
          if (state.status == FormzSubmissionStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Registration failed'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create Account',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Username Field
            const _UsernameField(),
            const SizedBox(height: 16),
            
            // Email Field with Async Validation
            const _EmailField(),
            const SizedBox(height: 16),
            
            // Password Field with Dependent Validation
            const _PasswordField(),
            const SizedBox(height: 24),
            
            // Submit Button
            const _SubmitButton(),
          ],
        ),
      ),
    );
  }
}

/// Username Input Field
class _UsernameField extends StatelessWidget {
  const _UsernameField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          current is RegisterFormState &&
          previous is RegisterFormState,
      builder: (context, state) {
        if (state is! RegisterFormState) return const SizedBox();

        return TextFormField(
          onChanged: (value) {
            context.read<AuthBloc>().add(RegisterUsernameChanged(value));
          },
          decoration: InputDecoration(
            labelText: 'Username',
            prefixIcon: const Icon(Icons.person),
            errorText: state.hasSubmittedOnce && state.username.displayError != null
                ? state.username.errorMessage
                : null,
            helperText: !state.hasSubmittedOnce && state.username.isPure
                ? 'At least 3 characters, letters/numbers/underscores only'
                : null,
            helperMaxLines: 2,
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

/// Email Input Field with Async Validation Indicator
class _EmailField extends StatelessWidget {
  const _EmailField();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          current is RegisterFormState &&
          previous is RegisterFormState,
      builder: (context, state) {
        if (state is! RegisterFormState) return const SizedBox();

        return TextFormField(
          onChanged: (value) {
            context.read<AuthBloc>().add(RegisterEmailChanged(value));
            
            // Trigger async validation when email format is valid
            if (state.email.isValid) {
              context.read<AuthBloc>().add(const RegisterEmailValidationRequested());
            }
          },
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            suffixIcon: state.isEmailValidating
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : state.email.isValid && !state.email.isPure
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : null,
            errorText: state.hasSubmittedOnce && state.email.displayError != null
                ? state.email.errorMessage
                : null,
            helperText: !state.hasSubmittedOnce && state.email.isPure
                ? 'Enter a valid email address'
                : null,
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        );
      },
    );
  }
}

/// Password Input Field with Dependent Validation
class _PasswordField extends StatefulWidget {
  const _PasswordField();

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          current is RegisterFormState &&
          previous is RegisterFormState,
      builder: (context, state) {
        if (state is! RegisterFormState) return const SizedBox();

        return TextFormField(
          onChanged: (value) {
            context.read<AuthBloc>().add(RegisterPasswordChanged(value));
          },
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            errorText: state.hasSubmittedOnce && state.password.displayError != null
                ? state.password.errorMessage
                : null,
            helperText: !state.hasSubmittedOnce
                ? 'At least 6 characters, cannot contain username'
                : (state.password.displayError != null &&
                        state.password.error == PasswordValidationError.containsUsername
                    ? null
                    : 'Cannot contain your username'),
            helperMaxLines: 2,
            helperStyle: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            border: const OutlineInputBorder(),
          ),
        );
      },
    );
  }
}

/// Submit Button with Form Validation
class _SubmitButton extends StatelessWidget {
  const _SubmitButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) {
        if (current is! RegisterFormState || previous is! RegisterFormState) {
          return false;
        }
        
        return previous.status != current.status ||
            previous.isFormValid != current.isFormValid ||
            previous.isEmailValidating != current.isEmailValidating;
      },
      builder: (context, state) {
        if (state is! RegisterFormState) return const SizedBox();

        final isLoading = state.status == FormzSubmissionStatus.inProgress;
        final isEnabled = state.isFormValid && !isLoading;
        
        return ElevatedButton(
          onPressed: isEnabled
              ? () {
                  context.read<AuthBloc>().add(const RegisterSubmitted());
                }
              : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.blue,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Register',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
        );
      },
    );
  }
}
