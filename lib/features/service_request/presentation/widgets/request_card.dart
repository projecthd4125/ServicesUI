import 'package:flutter/material.dart';
import '../../data/service_request_model.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/responsive_utils.dart';
import 'status_badge.dart';

/// Card widget for displaying a service request
class RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;
  final bool showStatusMessage;

  const RequestCard({
    super.key,
    required this.request,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = false,
    this.showStatusMessage = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isTablet),
              const SizedBox(height: 12),
              _buildDateInfo(isTablet),
              const SizedBox(height: 8),
              _buildLocationInfo(isTablet),
              const SizedBox(height: 8),
              _buildPhoneInfo(isTablet),
              const SizedBox(height: 12),
              _buildDescription(isTablet),
              const SizedBox(height: 12),
              _buildStatusMessage(context, isTablet),
              const SizedBox(height: 8),
              _buildCreatedAt(isTablet),
              if (showActions) ...[
                const SizedBox(height: 12),
                _buildActions(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Request #${request.id}',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Show response indicator for admin when client has responded
        if (!showStatusMessage && request.adminMessage != null && request.clientResponse != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.mark_email_read_rounded,
                  size: isTablet ? 14 : 12,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  'Response',
                  style: TextStyle(
                    fontSize: isTablet ? 11 : 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        StatusBadge(
          status: request.status,
          fontSize: isTablet ? 12 : 10,
        ),
      ],
    );
  }

  Widget _buildDateInfo(bool isTablet) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: isTablet ? 18 : 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppDateUtils.formatDateRange(
              request.expectedStartDate,
              request.expectedEndDate,
            ),
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo(bool isTablet) {
    return Row(
      children: [
        Icon(
          Icons.location_on,
          size: isTablet ? 18 : 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            request.location,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneInfo(bool isTablet) {
    return Row(
      children: [
        Icon(
          Icons.phone,
          size: isTablet ? 18 : 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          request.formattedPhoneNumber,
          style: TextStyle(
            fontSize: isTablet ? 14 : 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(bool isTablet) {
    return Text(
      request.serviceDescription,
      style: TextStyle(
        fontSize: isTablet ? 14 : 13,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCreatedAt(bool isTablet) {
    return Text(
      'Created: ${AppDateUtils.formatDate(request.createdAt)}',
      style: TextStyle(
        fontSize: isTablet ? 12 : 11,
        color: Colors.grey[500],
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildStatusMessage(BuildContext context, bool isTablet) {
    // Only show status message in client view
    if (!showStatusMessage) {
      return const SizedBox.shrink();
    }

    final statusInfo = _getStatusInfo();
    
    // Don't show message for pending or completed states
    if (statusInfo == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusInfo.color.withValues(alpha: 0.1),
            statusInfo.color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusInfo.color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusInfo.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  statusInfo.icon,
                  color: statusInfo.color,
                  size: isTablet ? 24 : 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusInfo.title,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.bold,
                        color: statusInfo.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusInfo.message,
                      style: TextStyle(
                        fontSize: isTablet ? 13 : 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                    // Show admin message if it exists (for needMoreInfo status)
                    if (request.status == RequestStatus.needMoreInfo && 
                        request.adminMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.admin_panel_settings_rounded,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Admin Request:',
                                  style: TextStyle(
                                    fontSize: isTablet ? 13 : 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              request.adminMessage!,
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 12,
                                color: Colors.grey[800],
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Show client response if exists
                      if (request.clientResponse != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: Colors.green[700],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Your Response:',
                                    style: TextStyle(
                                      fontSize: isTablet ? 13 : 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                request.clientResponse!,
                                style: TextStyle(
                                  fontSize: isTablet ? 13 : 12,
                                  color: Colors.grey[800],
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                    // Show payment information if it exists (for payment status)
                    if (request.status == RequestStatus.payment && 
                        request.paymentInfo != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.shade300, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_rounded,
                                  size: 16,
                                  color: Colors.purple[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Payment Details:',
                                  style: TextStyle(
                                    fontSize: isTablet ? 13 : 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.paymentInfo!,
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 12,
                                color: Colors.grey[800],
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Show assigned provider information if it exists
                    if (request.status == RequestStatus.providerAssigned && 
                        request.assignedProviderEmail != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.deepPurple.shade300, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.engineering_rounded,
                                  size: 16,
                                  color: Colors.deepPurple[700],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Assigned Service Provider:',
                                  style: TextStyle(
                                    fontSize: isTablet ? 13 : 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              request.assignedProviderEmail!,
                              style: TextStyle(
                                fontSize: isTablet ? 13 : 12,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Show response button if admin message exists and no client response yet
          if (request.status == RequestStatus.needMoreInfo && 
              request.adminMessage != null && 
              request.clientResponse == null &&
              showActions) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: onTap,
                icon: const Icon(Icons.reply_rounded, size: 18),
                label: const Text('Provide Information'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber.shade600,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
          // Show "Mark as Paid" button if payment status and payment info exists
          if (request.status == RequestStatus.payment && 
              request.paymentInfo != null &&
              showActions) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.check_circle_rounded, size: 20),
                label: const Text('Mark as Paid'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _StatusInfo? _getStatusInfo() {
    switch (request.status) {
      case RequestStatus.inReview:
        return _StatusInfo(
          icon: Icons.rate_review_rounded,
          color: Colors.blue,
          title: '🎉 Thanks for requesting service!',
          message: 'Your request is currently under review. Our team is carefully examining your requirements and will get back to you soon with next steps.',
        );
      
      case RequestStatus.needMoreInfo:
        return _StatusInfo(
          icon: Icons.info_outline_rounded,
          color: Colors.amber.shade700,
          title: '📋 Additional Information Needed',
          message: 'We need a bit more information to process your request. Please check your messages or contact us to provide the required details.',
        );
      
      case RequestStatus.accepted:
        return _StatusInfo(
          icon: Icons.check_circle_outline_rounded,
          color: Colors.green,
          title: '✨ Great News - Request Accepted!',
          message: 'Your service request has been accepted! We\'re excited to serve you. You\'ll be notified about the next steps shortly.',
        );
      
      case RequestStatus.payment:
        return _StatusInfo(
          icon: Icons.payment_rounded,
          color: Colors.purple,
          title: '💳 Payment Information',
          message: 'Please review the payment details below and complete the payment to proceed with your service.',
        );
      
      case RequestStatus.paid:
        return _StatusInfo(
          icon: Icons.verified_rounded,
          color: Colors.teal,
          title: '✅ Payment Confirmed!',
          message: 'Thank you for your payment! Your request is now being processed and will be approved shortly.',
        );
      
      case RequestStatus.paymentReceived:
        return _StatusInfo(
          icon: Icons.account_balance_wallet_rounded,
          color: Colors.cyan.shade700,
          title: '💰 Payment Received',
          message: 'Your payment has been received and verified! We are now in the process of assigning a service provider to your request.',
        );
      
      case RequestStatus.assigningProvider:
        return _StatusInfo(
          icon: Icons.person_search_rounded,
          color: Colors.indigo,
          title: '🔍 Finding Your Service Provider',
          message: 'We are actively searching for the best service provider to match your requirements. You will be notified once a provider is assigned.',
        );
      
      case RequestStatus.providerAssigned:
        return _StatusInfo(
          icon: Icons.engineering_rounded,
          color: Colors.deepPurple,
          title: '👨‍🔧 Service Provider Assigned!',
          message: 'Great news! A service provider has been assigned to your request and will contact you soon to confirm the details and schedule.',
        );
      
      case RequestStatus.approved:
        return _StatusInfo(
          icon: Icons.thumb_up_outlined,
          color: Colors.green.shade600,
          title: '✅ Request Approved',
          message: 'Your request has been approved and is being processed. A service provider will be assigned soon.',
        );
      
      case RequestStatus.rejected:
        return _StatusInfo(
          icon: Icons.info_outline_rounded,
          color: Colors.red.shade600,
          title: '💬 Thank You for Your Interest',
          message: 'We truly appreciate you reaching out to us. After careful '
              'review, we regret that we\'re unable to fulfill this particular '
              'request at this time. We value your understanding and would be '
              'happy to discuss alternative options or answer any questions '
              'you may have. Please feel free to contact us or submit a '
              'new request.',
        );
      
      case RequestStatus.completed:
        return _StatusInfo(
          icon: Icons.celebration_outlined,
          color: Colors.purple,
          title: '🎊 Service Completed!',
          message: 'Thank you for choosing our services! We hope you had a great experience. Feel free to leave feedback.',
        );
      
      case RequestStatus.pending:
      default:
        return null; // No special message for pending
    }
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (onEdit != null)
          OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
        if (onEdit != null && onDelete != null) const SizedBox(width: 8),
        if (onDelete != null)
          OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
      ],
    );
  }
}

/// Helper class for status message information
class _StatusInfo {
  final IconData icon;
  final Color color;
  final String title;
  final String message;

  _StatusInfo({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });
}
