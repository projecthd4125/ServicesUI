import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/service_request_model.dart';
import '../data/service_request_service.dart';
import 'widgets/request_card.dart';
import 'widgets/empty_requests_widget.dart';
import 'create_request_screen.dart';

/// Screen for displaying client's service requests
class ClientRequestsScreen extends StatefulWidget {
  const ClientRequestsScreen({super.key});

  @override
  State<ClientRequestsScreen> createState() => _ClientRequestsScreenState();
}

class _ClientRequestsScreenState extends State<ClientRequestsScreen> {
  List<ServiceRequest> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    final currentUser = AuthService.currentUser;
    if (currentUser != null) {
      final requests =
          await ServiceRequestService.getRequestsByClient(currentUser.email);
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToCreateRequest() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => const CreateRequestScreen(),
      ),
    );

    if (result == true) {
      _loadRequests();
    }
  }

  Future<void> _navigateToEditRequest(ServiceRequest request) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => CreateRequestScreen(existingRequest: request),
      ),
    );

    if (result == true) {
      _loadRequests();
    }
  }

  Future<void> _deleteRequest(ServiceRequest request) async {
    final confirmed = await _showDeleteConfirmation(request);
    if (confirmed != true) return;

    _showLoadingSnackBar('Deleting request...');

    final result = await ServiceRequestService.deleteRequest(request.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result.success) {
      _showSuccessSnackBar(result.message);
      _loadRequests();
    } else {
      _showErrorSnackBar(result.message);
    }
  }

  Future<void> _handleRequestTap(ServiceRequest request) async {
    // Handle "Provide Information" for needMoreInfo status
    if (request.status == RequestStatus.needMoreInfo && 
        request.adminMessage != null &&
        request.clientResponse == null) {
      final response = await _showResponseDialog(request);
      if (response != null && response.isNotEmpty) {
        _showLoadingSnackBar('Sending response...');
        
        final updatedRequest = request.copyWith(
          clientResponse: response,
          responseDate: DateTime.now(),
        );
        
        final result = await ServiceRequestService.updateRequest(updatedRequest);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (result.success) {
          _showSuccessSnackBar('Response sent successfully!');
          _loadRequests();
        } else {
          _showErrorSnackBar(result.message);
        }
      }
    }
    // Handle "Mark as Paid" for payment status
    else if (request.status == RequestStatus.payment && 
             request.paymentInfo != null) {
      final confirmed = await _showPaymentConfirmationDialog();
      if (confirmed == true) {
        _showLoadingSnackBar('Updating payment status...');
        
        final result = await ServiceRequestService.updateRequestStatus(
          request.id, 
          RequestStatus.paid,
        );
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        if (result.success) {
          _showSuccessSnackBar('Payment status updated successfully!');
          _loadRequests();
        } else {
          _showErrorSnackBar(result.message);
        }
      }
    }
  }

  Future<bool?> _showPaymentConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.teal),
            SizedBox(width: 8),
            Text('Confirm Payment'),
          ],
        ),
        content: const Text(
          'Have you completed the payment as per the instructions provided?\n\n'
          'By clicking "Yes, I\'ve Paid", you confirm that the payment has been made.',
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.check_circle, size: 18),
            label: const Text('Yes, I\'ve Paid'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showResponseDialog(ServiceRequest request) async {
    final TextEditingController controller = TextEditingController();
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.reply_rounded, color: Colors.amber),
            SizedBox(width: 8),
            Text('Provide Additional Information'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      request.adminMessage!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[800],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your Response:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Provide the requested information here...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
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
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            icon: const Icon(Icons.send, size: 18),
            label: const Text('Send Response'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(ServiceRequest request) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text(
          'Are you sure you want to delete this service request?\n\n'
          'Request #${request.id}\n'
          'Location: ${request.location}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              AuthService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showLoadingSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Service Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _requests.isEmpty
              ? EmptyRequestsWidget(
                  message: 'No service requests yet',
                  subtitle: 'Create your first service request',
                  isTablet: isTablet,
                )
              : ListView.builder(
                  padding: ResponsiveUtils.getResponsivePadding(context),
                  itemCount: _requests.length,
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return RequestCard(
                      request: request,
                      showActions: true,
                      onTap: () => _handleRequestTap(request),
                      onEdit: () => _navigateToEditRequest(request),
                      onDelete: () => _deleteRequest(request),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateRequest,
        icon: const Icon(Icons.add),
        label: Text(isTablet ? 'New Request' : 'New'),
      ),
    );
  }
}
