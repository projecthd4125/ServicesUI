import 'package:flutter/material.dart';
import '../data/service_request_model.dart';
import '../data/service_request_service.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/presentation/login_screen.dart';
import 'widgets/request_card.dart';

/// Service Provider requests screen
class ProviderRequestsScreen extends StatefulWidget {
  const ProviderRequestsScreen({super.key});

  @override
  State<ProviderRequestsScreen> createState() => _ProviderRequestsScreenState();
}

class _ProviderRequestsScreenState extends State<ProviderRequestsScreen> {
  List<ServiceRequest> _requests = [];
  bool _isLoading = true;
  RequestStatus? _filterStatus;
  String? _providerEmail;

  @override
  void initState() {
    super.initState();
    _loadProviderEmail();
  }

  Future<void> _loadProviderEmail() async {
    // Get current logged in user email from auth service
    final user = AuthService.currentUser;
    if (user != null) {
      _providerEmail = user.email;
      _loadRequests();
    }
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);

    final result = await ServiceRequestService.getAllRequests();

    if (!mounted) return;

    setState(() {
      // Filter only requests assigned to this provider
      _requests = result
          .where((r) => r.assignedProviderEmail == _providerEmail)
          .toList();
      _isLoading = false;
    });
  }

  List<ServiceRequest> get _filteredRequests {
    if (_filterStatus == null) return _requests;
    return _requests.where((r) => r.status == _filterStatus).toList();
  }

  int get _totalRequests => _requests.length;
  int get _assignedCount => _requests.where((r) => r.status == RequestStatus.providerAssigned).length;
  int get _inProgressCount => _requests.where((r) => r.status == RequestStatus.approved).length;
  int get _completedCount => _requests.where((r) => r.status == RequestStatus.completed).length;

  Future<void> _handleLogout() async {
    AuthService.logout();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Assigned Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadRequests,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 12),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(ResponsiveUtils.getResponsivePadding(context).horizontal),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildSummaryCards(isTablet),
                    const SizedBox(height: 24),
                    Text(
                      'Filter by Status',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFilterChips(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _isLoading
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _filteredRequests.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No requests assigned yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
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
                                  showStatusMessage: true,
                                  onTap: () => _showRequestDetails(request),
                                ),
                              );
                            },
                            childCount: _filteredRequests.length,
                          ),
                        ),
                      ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
        _buildSummaryCard(
          'Total',
          _totalRequests,
          Colors.blue,
          Icons.assignment_rounded,
        ),
        _buildSummaryCard(
          'Assigned',
          _assignedCount,
          Colors.deepPurple,
          Icons.engineering_rounded,
        ),
        _buildSummaryCard(
          'In Progress',
          _inProgressCount,
          Colors.orange,
          Icons.work_outline_rounded,
        ),
        _buildSummaryCard(
          'Completed',
          _completedCount,
          Colors.green,
          Icons.check_circle_outline_rounded,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, int value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          if (title == 'Total') {
            setState(() => _filterStatus = null);
          } else if (title == 'Assigned') {
            setState(() => _filterStatus = RequestStatus.providerAssigned);
          } else if (title == 'In Progress') {
            setState(() => _filterStatus = RequestStatus.approved);
          } else if (title == 'Completed') {
            setState(() => _filterStatus = RequestStatus.completed);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    final filterOptions = {
      null: 'All',
      RequestStatus.providerAssigned: isMobile ? 'Assigned' : 'Assign Service Provider',
      RequestStatus.approved: 'Approved',
      RequestStatus.completed: isMobile ? 'Complete' : 'Completed',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterOptions.entries.map((entry) {
          final isLast = entry.key == RequestStatus.completed;
          return Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8),
            child: _buildFilterChip(entry.key, entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterChip(RequestStatus? status, String label) {
    final isSelected = _filterStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _filterStatus = selected ? status : null);
      },
    );
  }

  void _showRequestDetails(ServiceRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Request #${request.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Status', request.status.displayName),
              _buildDetailRow('Client', request.clientEmail),
              _buildDetailRow('Location', request.location),
              _buildDetailRow('Contact', request.formattedPhoneNumber),
              _buildDetailRow(
                'Service Period',
                AppDateUtils.formatDateRange(
                  request.expectedStartDate,
                  request.expectedEndDate,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(request.serviceDescription),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
