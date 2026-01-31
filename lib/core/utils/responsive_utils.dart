import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Utility class for responsive design helpers
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 
        AppConstants.tabletBreakpoint;
  }

  /// Check if device is a desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 
        AppConstants.desktopBreakpoint;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return !isTablet(context);
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final isTabletDevice = isTablet(context);
    return EdgeInsets.all(isTabletDevice ? 32 : 16);
  }

  /// Get responsive horizontal padding
  static EdgeInsets getHorizontalPadding(BuildContext context) {
    final isTabletDevice = isTablet(context);
    return EdgeInsets.symmetric(horizontal: isTabletDevice ? 80 : 24);
  }

  /// Get responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
  }) {
    return isTablet(context) ? tablet : mobile;
  }
}
