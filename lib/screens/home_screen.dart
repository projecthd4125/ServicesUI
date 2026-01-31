import 'package:flutter/material.dart';
import '../features/auth/data/auth_service.dart';
import '../features/auth/data/user_model.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/service_request/presentation/client_requests_screen.dart';
import '../features/service_request/presentation/admin_requests_screen.dart';
import '../core/utils/responsive_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _handleLogout(BuildContext context) {
    AuthService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    final isTablet = ResponsiveUtils.isTablet(context);

    if (user == null) {
      return const LoginScreen();
    }

    // Route to role-specific screens
    if (user.role == UserRole.client) {
      return const ClientRequestsScreen();
    } else if (user.role == UserRole.admin) {
      return const AdminRequestsScreen();
    }

    // Default home screen for Service Provider (to be implemented later)
    return Scaffold(
      appBar: AppBar(
        title: Text(isTablet ? 'MyService (Tablet/iPad)' : 'MyService (Mobile)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getRoleIcon(user.role),
                size: isTablet ? 120 : 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome, ${user.role.displayName}!',
                style: TextStyle(
                  fontSize: isTablet ? 32 : 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Email: ${user.email}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Role: ${user.role.displayName}',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isTablet
                    ? 'You are viewing this on a Tablet/iPad'
                    : 'You are viewing this on a Mobile device',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Service Provider functionality will be implemented in the next steps.',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings;
      case UserRole.client:
        return Icons.person;
      case UserRole.serviceProvider:
        return Icons.business_center;
    }
  }
}
