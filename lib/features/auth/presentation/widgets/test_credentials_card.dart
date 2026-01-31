import 'package:flutter/material.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/constants/test_credentials.dart';

/// Widget displaying test credentials for development
class TestCredentialsCard extends StatelessWidget {
  const TestCredentialsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Test Credentials:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTablet ? 16 : 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildCredentialLine('Admin', TestCredentials.adminEmail, isTablet),
          _buildCredentialLine('Client', TestCredentials.clientEmail, isTablet),
          Text(
            'Service Providers:',
            style: TextStyle(
              fontSize: isTablet ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          ...TestCredentials.serviceProviders.map(
            (email) => Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                '• $email',
                style: TextStyle(fontSize: isTablet ? 12 : 10),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Password: ${TestCredentials.testPassword}',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialLine(String role, String email, bool isTablet) {
    return Text(
      '$role: $email',
      style: TextStyle(fontSize: isTablet ? 14 : 12),
    );
  }
}
