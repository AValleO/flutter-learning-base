import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          ListTile(
            title: Text('Cubits'),
            subtitle: Text('Gestor Estados con Cubit'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => context.push('/cubits'),
          ),
          ListTile(
            title: Text('Blocs'),
            subtitle: Text('Gestor Estados con Bloc'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () => context.push('/blocs'),
          ),
        ],
      ),
    );
  }
}