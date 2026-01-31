import 'package:flutter/material.dart';
import '../../data/service_request_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Badge widget for displaying request status
class StatusBadge extends StatelessWidget {
  final RequestStatus status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 10,
  });

  Color _getStatusColor() {
    switch (status) {
      case RequestStatus.pending:
        return AppTheme.pendingColor;
      case RequestStatus.inReview:
        return Colors.blue;
      case RequestStatus.needMoreInfo:
        return Colors.amber;
      case RequestStatus.accepted:
        return Colors.green;
      case RequestStatus.payment:
        return Colors.purple;
      case RequestStatus.paid:
        return Colors.teal;
      case RequestStatus.paymentReceived:
        return Colors.cyan.shade700;
      case RequestStatus.assigningProvider:
        return Colors.indigo;
      case RequestStatus.providerAssigned:
        return Colors.deepPurple;
      case RequestStatus.approved:
        return AppTheme.approvedColor;
      case RequestStatus.rejected:
        return AppTheme.rejectedColor;
      case RequestStatus.completed:
        return AppTheme.completedColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.upperCaseName,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
