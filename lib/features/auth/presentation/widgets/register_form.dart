/*import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_4/core/utils/validation_rules.dart';
import 'package:flutter_application_4/features/auth/presentation/blocs/bloc/auth_bloc.dart';
import 'package:flutter_application_4/shared/widgets/inputs/custom_text_form_field.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';
  
  // Control when validation starts
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  
  // Track if form is valid
  bool _isFormValid = false;
  
  // Check form validity
  void _checkFormValidity() {
    final isValid = ValidationRules.isUsernameValid(_username) &&
                    ValidationRules.isEmailValid(_email) &&
                    ValidationRules.isPasswordValid(_password);
    
    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('¡Registro exitoso! Bienvenido ${state.user.username}'),
              backgroundColor: Colors.green,
            ),
          );
          // TODO: Navigate to home screen
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FlutterLogo(size: 100),
          SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CustomTextFormField(
                label: 'Nombre de usuario',
                hintText: 'Ingrese su nombre de usuario',
                onChanged: (value) {
                  _username = value;
                  _checkFormValidity();
                },
                validator: ValidationRules.validateUsername,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CustomTextFormField(
                label: 'Correo electrónico',
                hintText: 'Ingrese su correo electrónico',
                onChanged: (value) {
                  _email = value;
                  _checkFormValidity();
                },
                validator: ValidationRules.validateEmail,
              ),
            ),
          ),
          SizedBox(height: 10),
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: CustomTextFormField(
                label: 'Contraseña',
                hintText: 'Ingrese su contraseña',
                obscureText: true,
                onChanged: (value) {
                  _password = value;
                  _checkFormValidity();
                },
                validator: ValidationRules.validatePassword,
              ),
            ),
          ),
          SizedBox(height: 20),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              
              return FilledButton.tonalIcon(
                onPressed: (isLoading || !_isFormValid) ? null : () {
                  // Enable real-time validation after first submit attempt
                  setState(() {
                    _autovalidateMode = AutovalidateMode.onUserInteraction;
                  });
                  
                  if (_formKey.currentState!.validate()) {
                    // Dispatch event to BLoC
                    context.read<AuthBloc>().add(
                      RegisterSubmitted(
                        username: _username,
                        email: _email,
                        password: _password,
                      ),
                    );
                  }
                },
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.person_add_alt_1_outlined),
                label: Text(isLoading ? 'Registrando...' : 'Registrarse'),
              );
            },
          ),
          SizedBox(height: 10),
        ],
      ),
      ),
    );
  }
}*/