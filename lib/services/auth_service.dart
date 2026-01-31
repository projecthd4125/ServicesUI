import '../models/user.dart';

class AuthService {
  // Local test credentials
  static final List<User> _users = [
    User(
      email: 'admin@gmail.com',
      password: 'test123',
      role: UserRole.admin,
    ),
    User(
      email: 'client@gmail.com',
      password: 'test123',
      role: UserRole.client,
    ),
    User(
      email: 'serviceprovider@gmail.com',
      password: 'test123',
      role: UserRole.serviceProvider,
    ),
  ];

  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static Future<Map<String, dynamic>> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      final user = _users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase() && user.password == password,
      );
      _currentUser = user;
      return {
        'success': true,
        'user': user,
        'message': 'Login successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid email or password',
      };
    }
  }

  static void logout() {
    _currentUser = null;
  }

  static bool isLoggedIn() {
    return _currentUser != null;
  }

  static String getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.client:
        return 'Client';
      case UserRole.serviceProvider:
        return 'Service Provider';
    }
  }
}
