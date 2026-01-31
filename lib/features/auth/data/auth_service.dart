import '../data/user_model.dart';
import '../../../core/constants/test_credentials.dart';
import '../../../core/constants/app_constants.dart';

/// Authentication service for managing user login/logout
class AuthService {
  AuthService._();

  // Test users for development
  // TODO: Replace with real authentication when backend is ready
  static final List<User> _testUsers = [
    const User(
      email: TestCredentials.adminEmail,
      password: TestCredentials.testPassword,
      role: UserRole.admin,
    ),
    const User(
      email: TestCredentials.clientEmail,
      password: TestCredentials.testPassword,
      role: UserRole.client,
    ),
    const User(
      email: TestCredentials.serviceProviderEmail,
      password: TestCredentials.testPassword,
      role: UserRole.serviceProvider,
    ),
    // Additional service providers
    const User(
      email: 'serviceprovider1@gmail.com',
      password: TestCredentials.testPassword,
      role: UserRole.serviceProvider,
    ),
    const User(
      email: 'serviceprovider2@gmail.com',
      password: TestCredentials.testPassword,
      role: UserRole.serviceProvider,
    ),
    const User(
      email: 'serviceprovider3@gmail.com',
      password: TestCredentials.testPassword,
      role: UserRole.serviceProvider,
    ),
  ];

  static User? _currentUser;

  /// Get currently logged in user
  static User? get currentUser => _currentUser;

  /// Check if user is logged in
  static bool get isLoggedIn => _currentUser != null;

  /// Login with email and password
  static Future<AuthResult> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(AppConstants.apiDelay);

    try {
      final user = _testUsers.firstWhere(
        (user) =>
            user.email.toLowerCase() == email.toLowerCase() &&
            user.password == password,
      );

      _currentUser = user;

      return AuthResult.success(
        user: user,
        message: 'Login successful',
      );
    } catch (e) {
      return AuthResult.failure(
        message: 'Invalid email or password',
      );
    }
  }

  /// Logout current user
  static void logout() {
    _currentUser = null;
  }
}

/// Result of authentication operation
class AuthResult {
  final bool success;
  final User? user;
  final String message;

  const AuthResult._({
    required this.success,
    this.user,
    required this.message,
  });

  factory AuthResult.success({
    required User user,
    required String message,
  }) {
    return AuthResult._(
      success: true,
      user: user,
      message: message,
    );
  }

  factory AuthResult.failure({
    required String message,
  }) {
    return AuthResult._(
      success: false,
      message: message,
    );
  }
}
