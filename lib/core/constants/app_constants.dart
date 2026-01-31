/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'MyService UI';
  static const String appVersion = '1.0.0';

  // Responsive Breakpoints
  static const double tabletBreakpoint = 600.0;
  static const double desktopBreakpoint = 1024.0;

  // Storage Keys
  static const String serviceRequestsKey = 'service_requests';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // API Delays (for simulation)
  static const Duration apiDelay = Duration(milliseconds: 500);
}
