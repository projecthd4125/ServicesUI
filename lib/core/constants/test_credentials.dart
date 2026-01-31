/// Test credentials for development
/// TODO: Remove this file when implementing real authentication
class TestCredentials {
  TestCredentials._();

  static const String adminEmail = 'admin@gmail.com';
  static const String clientEmail = 'client@gmail.com';
  static const String serviceProviderEmail = 'serviceprovider@gmail.com';
  static const String testPassword = 'test123';
  
  // Service provider list
  static const List<String> serviceProviders = [
    'serviceprovider@gmail.com',
    'serviceprovider1@gmail.com',
    'serviceprovider2@gmail.com',
    'serviceprovider3@gmail.com',
  ];
}
