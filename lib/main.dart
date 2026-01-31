import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/auth/presentation/login_screen.dart';
import 'services/service_request_service.dart';

/// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local storage for service requests
  await ServiceRequestService.initialize();

  runApp(const MyServiceApp());
}

/// Root widget of the application
class MyServiceApp extends StatelessWidget {
  const MyServiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
