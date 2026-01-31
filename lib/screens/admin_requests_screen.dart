import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service_request.dart';
import '../services/service_request_service.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class AdminRequestsScreen extends StatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  State<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends State<AdminRequestsScreen> {
  List<ServiceRequest> _requests = [];

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final requests = await ServiceRequestService.getAllRequests();
    setState(() {
      _requests = requests;
    });
    // Debug: Print request count
    print('Admin loaded ${requests.length} requests');
  }

  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    final result = await ServiceRequestService.updateRequestStatus(
      requestId,
      newStatus,
    );

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
        ),
      );
      _loadRequests();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  void _showRequestDetails(ServiceRequest request) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final dateFormat = DateFormat('MMM dd, yyyy');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request #${request.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Client', request.clientEmail, isTablet),
              const SizedBox(height: 12),
              _buildDetailRow(
                'Start Date',
                dateFormat.format(request.expectedStartDate),
                isTablet,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                'End Date',
                dateFormat.format(request.expectedEndDate),
                isTablet,
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Location', request.location, isTablet),
              const SizedBox(height: 12),
              _buildDetailRow('Status', request.status.toUpperCase(), isTablet),
              const SizedBox(height: 12),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request.serviceDescription),
              const SizedBox(height: 12),
              Text(
                'Created: ${dateFormat.format(request.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (request.status == 'pending') ...[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(request.id, 'approved');
              },
              child: const Text('Approve'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(request.id, 'rejected');
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: isTablet ? 14 : 13),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Service Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _requests.isEmpty
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(isTablet ? 32 : 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: isTablet ? 120 : 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No service requests',
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Summary Cards
                Padding(
                  padding: EdgeInsets.all(isTablet ? 24 : 16),
                  child: FutureBuilder<List<int>>(
                    future: Future.wait([
                      ServiceRequestService.getRequestCountByStatus('pending'),
                      ServiceRequestService.getRequestCountByStatus('approved'),
                    ]),
                    builder: (context, snapshot) {
                      final pendingCount = snapshot.data?[0] ?? 0;
                      final approvedCount = snapshot.data?[1] ?? 0;
                      
                      return Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard(
                              'Total',
                              _requests.length.toString(),
                              Colors.blue,
                              isTablet,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Pending',
                              pendingCount.toString(),
                              Colors.orange,
                              isTablet,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard(
                              'Approved',
                              approvedCount.toString(),
                              Colors.green,
                              isTablet,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Requests List
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: 8,
                    ),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: InkWell(
                          onTap: () => _showRequestDetails(request),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: EdgeInsets.all(isTablet ? 20 : 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Request #${request.id}',
                                            style: TextStyle(
                                              fontSize: isTablet ? 18 : 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            request.clientEmail,
                                            style: TextStyle(
                                              fontSize: isTablet ? 14 : 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(request.status),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        request.status.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isTablet ? 12 : 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: isTablet ? 18 : 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${dateFormat.format(request.expectedStartDate)} - ${dateFormat.format(request.expectedEndDate)}',
                                      style: TextStyle(
                                        fontSize: isTablet ? 14 : 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
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
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    Color color,
    bool isTablet,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
