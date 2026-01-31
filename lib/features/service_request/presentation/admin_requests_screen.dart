import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/test_credentials.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/service_request_model.dart';
import '../data/service_request_service.dart';
import 'widgets/empty_requests_widget.dart';
import 'widgets/request_card.dart';
import 'widgets/summary_card.dart';

/// Admin dashboard to view and manage all service requests
class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  List<ServiceRequest> _requests = [];
  RequestStatus? _filterStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(AppConstants.apiDelay);
    final requests = await ServiceRequestService.getAllRequests();

    if (mounted) {
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  List<ServiceRequest> get _filteredRequests {
    if (_filterStatus == null) return _requests;
    return _requests.where((r) => r.status == _filterStatus).toList();
  }

  int get _totalRequests => _requests.length;
  int get _inReviewCount => _requests.where((r) => r.status == RequestStatus.inReview).length;
  int get _needMoreInfoCount => _requests.where((r) => r.status == RequestStatus.needMoreInfo).length;
  int get _acceptedCount => _requests.where((r) => r.status == RequestStatus.accepted).length;

  Future<void> _handleStatusUpdate(ServiceRequest request, RequestStatus newStatus) async {
    // If status is "Need More Information", show dialog to get admin message
    if (newStatus == RequestStatus.needMoreInfo) {
      final message = await _showAdminMessageDialog();
      if (message == null || message.isEmpty) {
        return; // User cancelled or didn't provide message
      }
      
      // Update with admin message
      final updatedRequest = request.copyWith(
        status: newStatus,
        adminMessage: message,
        clientResponse: null, // Clear any previous response
      );
      
      final result = await ServiceRequestService.updateRequest(updatedRequest);
      
      if (!mounted) return;
      
      if (result.success) {
        _showSuccessMessage('Information request sent to client successfully');
        await _loadRequests();
      } else {
        _showErrorMessage(result.message);
      }
    } else if (newStatus == RequestStatus.payment) {
      // If status is "Payment", show dialog to get payment information
      final paymentInfo = await _showPaymentInfoDialog();
      if (paymentInfo == null || paymentInfo.isEmpty) {
        return; // User cancelled or didn't provide payment info
      }
      
      // Update with payment information
      final updatedRequest = request.copyWith(
        status: newStatus,
        paymentInfo: paymentInfo,
        paymentInfoDate: DateTime.now(),
      );
      
      final result = await ServiceRequestService.updateRequest(updatedRequest);
      
      if (!mounted) return;
      
      if (result.success) {
        _showSuccessMessage('Payment information sent to client successfully');
        await _loadRequests();
      } else {
        _showErrorMessage(result.message);
      }
    } else if (newStatus == RequestStatus.providerAssigned) {
      // If status is "Provider Assigned", show dialog to select provider
      final providerEmail = await _showProviderSelectionDialog();
      if (providerEmail == null || providerEmail.isEmpty) {
        return; // User cancelled or didn't select provider
      }
      
      // Update with provider assignment
      final updatedRequest = request.copyWith(
        status: newStatus,
        assignedProviderEmail: providerEmail,
        providerAssignedDate: DateTime.now(),
      );
      
      final result = await ServiceRequestService.updateRequest(updatedRequest);
      
      if (!mounted) return;
      
      if (result.success) {
        _showSuccessMessage('Service provider assigned successfully');
        await _loadRequests();
      } else {
        _showErrorMessage(result.message);
      }
    } else {
      // Regular status update
      final result = await ServiceRequestService.updateRequestStatus(request.id, newStatus);

      if (!mounted) return;

      if (result.success) {
        _showSuccessMessage('Request ${newStatus.displayName.toLowerCase()} successfully');
        await _loadRequests();
      } else {
        _showErrorMessage(result.message);
      }
    }
  }

  Future<String?> _showAdminMessageDialog() async {
    final TextEditingController controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Additional Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please specify what additional information you need from the client:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'e.g., "Could you please provide more details about the specific location and any access requirements?"',
                border: OutlineInputBorder(),
                labelText: 'Your Message',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showPaymentInfoDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Payment Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please provide payment details to the client:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'e.g., "Payment Details:\n\nTotal Amount: \$XXX\nPayment Method: Bank Transfer\nAccount Number: XXXXXXXXXX\nDue Date: DD/MM/YYYY\n\nPlease make the payment and share the transaction receipt."',
                border: OutlineInputBorder(),
                labelText: 'Payment Information',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Send Payment Info'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showProviderSelectionDialog() async {
    String? selectedProvider;
    
    return showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.engineering_rounded, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text('Assign Service Provider'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Select a service provider to assign to this request:',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                // List of service providers
                ...TestCredentials.serviceProviders.map((provider) {
                  final isSelected = selectedProvider == provider;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setDialogState(() {
                          selectedProvider = provider;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
                          border: Border.all(
                            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? Colors.deepPurple : Colors.grey,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Icon(Icons.person_rounded, 
                              color: isSelected ? Colors.deepPurple.shade700 : Colors.grey.shade600,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                provider,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  color: isSelected ? Colors.deepPurple.shade900 : Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'The client will be notified about the provider assignment.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: selectedProvider != null 
                  ? () => Navigator.of(context).pop(selectedProvider)
                  : null,
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Assign Provider'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(ServiceRequest request) {
    RequestStatus selectedStatus = request.status;
    
    // Phase 1 workflow statuses
    final phase1Statuses = [
      RequestStatus.inReview,
      RequestStatus.needMoreInfo,
      RequestStatus.accepted,
      RequestStatus.rejected,
    ];
    
    // Phase 2 workflow statuses (after accepted)
    final phase2Statuses = [
      RequestStatus.payment,
    ];
    
    // Phase 3 workflow statuses (after payment received)
    final phase3Statuses = [
      RequestStatus.assigningProvider,
    ];
    
    // Determine which statuses to show based on current status
    List<RequestStatus> availableStatuses;
    if (request.status == RequestStatus.accepted) {
      // After accepted, show only Payment option
      availableStatuses = phase2Statuses;
    } else if (request.status == RequestStatus.payment) {
      // After payment sent (waiting for client to pay), can only mark as approved or rejected
      availableStatuses = [RequestStatus.approved, RequestStatus.rejected];
    } else if (request.status == RequestStatus.paid) {
      // After client marked as paid, admin confirms payment received or rejects
      availableStatuses = [RequestStatus.paymentReceived, RequestStatus.rejected];
    } else if (request.status == RequestStatus.paymentReceived) {
      // After payment received, move to assigning provider
      availableStatuses = phase3Statuses;
    } else if (request.status == RequestStatus.assigningProvider) {
      // After assigning provider, admin selects provider assigned
      availableStatuses = [RequestStatus.providerAssigned, RequestStatus.rejected];
    } else if (request.status == RequestStatus.providerAssigned) {
      // After provider assigned, can approve or reject
      availableStatuses = [RequestStatus.approved, RequestStatus.rejected];
    } else {
      // Phase 1: show all phase 1 statuses except current
      availableStatuses = phase1Statuses
          .where((status) => status != request.status)
          .toList();
    }
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Update Request Status'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Current Status: ${request.status.displayName}'),
                
                // Show admin message and client response if they exist
                if (request.adminMessage != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.admin_panel_settings_rounded, size: 18, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Your Information Request:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      request.adminMessage!,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                  
                  if (request.clientResponse != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.reply_rounded, size: 18, color: Colors.green[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Client Response:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(
                        request.clientResponse!,
                        style: const TextStyle(fontSize: 13, height: 1.4),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.pending_outlined, size: 18, color: Colors.amber[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Waiting for client response...',
                              style: TextStyle(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.amber[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(),
                ],
                
                // Show payment information if it exists
                if (request.paymentInfo != null) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.payment_rounded, size: 18, color: Colors.purple[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Information Sent:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Text(
                      request.paymentInfo!,
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                ],
                
                const SizedBox(height: 16),
                const Text('Select new status:'),
                const SizedBox(height: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: availableStatuses.map((status) {
                    final isSelected = selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setDialogState(() {
                            selectedStatus = status;
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue.shade50 : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey.shade300,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                                color: isSelected ? Colors.blue : Colors.grey,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  status.displayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedStatus != request.status
                  ? () {
                      Navigator.of(context).pop();
                      _handleStatusUpdate(request, selectedStatus);
                    }
                  : null,
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              AuthService.logout();
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadRequests,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRequests,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: ResponsiveUtils.getResponsivePadding(context),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildSummaryCards(isTablet),
                          const SizedBox(height: 16),
                          _buildFilterChips(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _filteredRequests.isEmpty
                      ? SliverFillRemaining(
                          child: EmptyRequestsWidget(
                            message: _filterStatus == null
                                ? 'No Requests Yet'
                                : 'No ${_filterStatus!.displayName} Requests',
                            subtitle: _filterStatus == null
                                ? 'Service requests will appear here once clients submit them.'
                                : null,
                          ),
                        )
                      : SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.getResponsivePadding(context).horizontal,
                          ),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final request = _filteredRequests[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: RequestCard(
                                    request: request,
                                    showActions: false,
                                    showStatusMessage: false,
                                    onTap: () => _showStatusUpdateDialog(request),
                                  ),
                                );
                              },
                              childCount: _filteredRequests.length,
                            ),
                          ),
                        ),
                  const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards(bool isTablet) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 400 ? 2 : (screenWidth < 800 ? 4 : 4);
    final aspectRatio = screenWidth < 400 ? 1.4 : (screenWidth < 600 ? 1.6 : (screenWidth < 1200 ? 2.0 : 2.5));
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: aspectRatio,
      children: [
        SummaryCard(
          title: 'Total',
          value: _totalRequests,
          color: Theme.of(context).colorScheme.primary,
          icon: Icons.request_page,
        ),
        SummaryCard(
          title: 'In Review',
          value: _inReviewCount,
          color: Colors.blue,
          icon: Icons.rate_review,
        ),
        SummaryCard(
          title: 'Need More Info',
          value: _needMoreInfoCount,
          color: Colors.amber,
          icon: Icons.info_outline,
        ),
        SummaryCard(
          title: 'Accepted',
          value: _acceptedCount,
          color: Colors.green,
          icon: Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(null, 'All'),
          const SizedBox(width: 8),
          ...RequestStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(status, status.displayName),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(RequestStatus? status, String label) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterStatus = selected ? status : null;
        });
      },
    );
  }
}
