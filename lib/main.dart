import 'package:flutter/material.dart';
import 'package:flutter_application_4/app/app.dart';
import 'package:flutter_application_4/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  runApp(const MyApp());
}
