import 'package:flutter/material.dart';
import 'package:flutter_application_4/config/router/app_router.dart';
import 'package:flutter_application_4/core/theme/app_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      title: 'Forms App',
      theme: AppTheme(selectedColorIndex: 2).theme(),
    );
  }
}