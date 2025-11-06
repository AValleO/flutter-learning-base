import 'package:flutter/material.dart';
import 'package:flutter_application_4/features/auth/presentation/pages/register_page.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Usuario'),
      ),
      body: RegisterPage(),
    );
  }
}