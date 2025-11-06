import 'package:flutter_application_4/features/auth/auth.dart';
import 'package:flutter_application_4/features/home/home.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/cubits',
      builder: (context, state) => const CubitCounterScreen(),
    ),
    GoRoute(
      path: '/blocs',
      builder: (context, state) => const BlocCounterScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
  ]
);