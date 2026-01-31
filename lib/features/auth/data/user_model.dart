/// User role enumeration
enum UserRole {
  admin,
  client,
  serviceProvider;

  /// Get display name for the role
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.client:
        return 'Client';
      case UserRole.serviceProvider:
        return 'Service Provider';
    }
  }

  /// Get icon for the role
  String get iconName {
    switch (this) {
      case UserRole.admin:
        return 'admin_panel_settings';
      case UserRole.client:
        return 'person';
      case UserRole.serviceProvider:
        return 'business_center';
    }
  }
}

/// User model
class User {
  final String email;
  final String password;
  final UserRole role;

  const User({
    required this.email,
    required this.password,
    required this.role,
  });

  /// Create a copy with updated fields
  User copyWith({
    String? email,
    String? password,
    UserRole? role,
  }) {
    return User(
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.email == email &&
        other.password == password &&
        other.role == role;
  }

  @override
  int get hashCode => Object.hash(email, password, role);

  @override
  String toString() => 'User(email: $email, role: ${role.displayName})';
}
