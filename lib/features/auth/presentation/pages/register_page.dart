import 'package:flutter/material.dart';
import 'package:flutter_application_4/features/auth/presentation/widgets/register_form_with_formz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_4/features/auth/presentation/blocs/bloc/auth_bloc.dart';
import 'package:flutter_application_4/injection_container.dart' as di;

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: SingleChildScrollView(
            child: BlocProvider(
              create: (context) => di.getIt<AuthBloc>(),
              child: const RegisterFormWithFormz(),
            ),
          ),
        ),
      ),
    );
  }
}