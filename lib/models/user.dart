enum UserRole {
  admin,
  client,
  serviceProvider,
}

class User {
  final String email;
  final String password;
  final UserRole role;

  User({
    required this.email,
    required this.password,
    required this.role,
  });
}
