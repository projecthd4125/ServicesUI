import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_request_model.dart';
import '../../../core/constants/app_constants.dart';

/// Service for managing service requests with local storage
class ServiceRequestService {
  ServiceRequestService._();

  // Local storage for service requests
  static List<ServiceRequest> _serviceRequests = [];
  static bool _isInitialized = false;

  /// Initialize and load data from local storage
  static Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final String? requestsJson = prefs.getString(AppConstants.serviceRequestsKey);

    if (requestsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(requestsJson);
        _serviceRequests = decoded
            .map((item) => ServiceRequest.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // If there's an error loading data, start with empty list
        _serviceRequests = [];
        print('Error loading service requests: $e');
      }
    }

    _isInitialized = true;
    print('ServiceRequestService initialized with ${_serviceRequests.length} requests');
  }

  /// Save data to local storage
  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        _serviceRequests.map((request) => request.toJson()).toList();
    await prefs.setString(AppConstants.serviceRequestsKey, json.encode(jsonList));
  }

  /// Get all service requests
  static Future<List<ServiceRequest>> getAllRequests() async {
    await initialize();
    return List.unmodifiable(_serviceRequests);
  }

  /// Get requests by client email
  static Future<List<ServiceRequest>> getRequestsByClient(
    String clientEmail,
  ) async {
    await initialize();
    return _serviceRequests
        .where((request) => request.clientEmail == clientEmail)
        .toList();
  }

  /// Get pending requests (for admin)
  static Future<List<ServiceRequest>> getPendingRequests() async {
    await initialize();
    return _serviceRequests
        .where((request) => request.status == RequestStatus.pending)
        .toList();
  }

  /// Get requests by status
  static Future<List<ServiceRequest>> getRequestsByStatus(
    RequestStatus status,
  ) async {
    await initialize();
    return _serviceRequests
        .where((request) => request.status == status)
        .toList();
  }

  /// Add a new service request
  static Future<ServiceRequestResult> addRequest(ServiceRequest request) async {
    await initialize();

    // Simulate network delay
    await Future.delayed(AppConstants.apiDelay);

    _serviceRequests.add(request);
    await _saveToStorage();

    print('Request added: ID=${request.id}, Client=${request.clientEmail}, Total=${_serviceRequests.length}');

    return ServiceRequestResult.success(
      message: 'Service request submitted successfully',
      request: request,
    );
  }

  /// Update request status
  static Future<ServiceRequestResult> updateRequestStatus(
    String requestId,
    RequestStatus newStatus,
  ) async {
    await initialize();

    // Simulate network delay
    await Future.delayed(AppConstants.apiDelay);

    final index = _serviceRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _serviceRequests[index] =
          _serviceRequests[index].copyWith(status: newStatus);
      await _saveToStorage();

      return ServiceRequestResult.success(
        message: 'Request status updated successfully',
      );
    }

    return ServiceRequestResult.failure(
      message: 'Request not found',
    );
  }

  /// Update entire request (for admin messages and client responses)
  static Future<ServiceRequestResult> updateRequest(
    ServiceRequest updatedRequest,
  ) async {
    await initialize();

    // Simulate network delay
    await Future.delayed(AppConstants.apiDelay);

    final index = _serviceRequests.indexWhere((r) => r.id == updatedRequest.id);
    if (index != -1) {
      _serviceRequests[index] = updatedRequest;
      await _saveToStorage();

      return ServiceRequestResult.success(
        message: 'Request updated successfully',
        request: updatedRequest,
      );
    }

    return ServiceRequestResult.failure(
      message: 'Request not found',
    );
  }

  /// Delete a request
  static Future<ServiceRequestResult> deleteRequest(String requestId) async {
    await initialize();

    // Simulate network delay
    await Future.delayed(AppConstants.apiDelay);

    final initialLength = _serviceRequests.length;
    _serviceRequests.removeWhere((r) => r.id == requestId);
    final removed = initialLength - _serviceRequests.length;

    if (removed > 0) {
      await _saveToStorage();

      return ServiceRequestResult.success(
        message: 'Request deleted successfully',
      );
    }

    return ServiceRequestResult.failure(
      message: 'Request not found',
    );
  }

  /// Get request count by status
  static Future<int> getRequestCountByStatus(RequestStatus status) async {
    await initialize();
    return _serviceRequests.where((r) => r.status == status).length;
  }

  /// Clear all data (useful for testing)
  static Future<void> clearAllData() async {
    _serviceRequests.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.serviceRequestsKey);
    print('All service requests cleared');
  }
}

/// Result of service request operation
class ServiceRequestResult {
  final bool success;
  final String message;
  final ServiceRequest? request;

  const ServiceRequestResult._({
    required this.success,
    required this.message,
    this.request,
  });

  factory ServiceRequestResult.success({
    required String message,
    ServiceRequest? request,
  }) {
    return ServiceRequestResult._(
      success: true,
      message: message,
      request: request,
    );
  }

  factory ServiceRequestResult.failure({
    required String message,
  }) {
    return ServiceRequestResult._(
      success: false,
      message: message,
    );
  }
}
