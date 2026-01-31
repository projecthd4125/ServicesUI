import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/service_request.dart';

class ServiceRequestService {
  static const String _storageKey = 'service_requests';
  
  // Local storage for service requests
  static List<ServiceRequest> _serviceRequests = [];
  static bool _isInitialized = false;

  // Initialize and load data from local storage
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    final String? requestsJson = prefs.getString(_storageKey);
    
    if (requestsJson != null) {
      try {
        final List<dynamic> decoded = json.decode(requestsJson);
        _serviceRequests = decoded
            .map((item) => ServiceRequest.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // If there's an error loading data, start with empty list
        _serviceRequests = [];
      }
    }
    
    _isInitialized = true;
  }

  // Save data to local storage
  static Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList =
        _serviceRequests.map((request) => request.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  // Get all service requests
  static Future<List<ServiceRequest>> getAllRequests() async {
    await initialize();
    return List.unmodifiable(_serviceRequests);
  }

  // Get requests by client email
  static Future<List<ServiceRequest>> getRequestsByClient(String clientEmail) async {
    await initialize();
    return _serviceRequests
        .where((request) => request.clientEmail == clientEmail)
        .toList();
  }

  // Get pending requests (for admin)
  static Future<List<ServiceRequest>> getPendingRequests() async {
    await initialize();
    return _serviceRequests
        .where((request) => request.status == 'pending')
        .toList();
  }

  // Add a new service request
  static Future<Map<String, dynamic>> addRequest(ServiceRequest request) async {
    await initialize();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _serviceRequests.add(request);
    await _saveToStorage();
    
    // Debug: Print request added
    print('Request added: ID=${request.id}, Client=${request.clientEmail}, Total=${_serviceRequests.length}');
    
    return {
      'success': true,
      'message': 'Service request submitted successfully',
      'request': request,
    };
  }

  // Update request status
  static Future<Map<String, dynamic>> updateRequestStatus(
    String requestId,
    String newStatus,
  ) async {
    await initialize();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _serviceRequests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      _serviceRequests[index] = _serviceRequests[index].copyWith(status: newStatus);
      await _saveToStorage();
      
      return {
        'success': true,
        'message': 'Request status updated successfully',
      };
    }
    return {
      'success': false,
      'message': 'Request not found',
    };
  }

  // Delete a request
  static Future<Map<String, dynamic>> deleteRequest(String requestId) async {
    await initialize();
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final initialLength = _serviceRequests.length;
    _serviceRequests.removeWhere((r) => r.id == requestId);
    final removed = initialLength - _serviceRequests.length;
    
    if (removed > 0) {
      await _saveToStorage();
      
      return {
        'success': true,
        'message': 'Request deleted successfully',
      };
    }
    return {
      'success': false,
      'message': 'Request not found',
    };
  }

  // Get request count by status
  static Future<int> getRequestCountByStatus(String status) async {
    await initialize();
    return _serviceRequests.where((r) => r.status == status).length;
  }

  // Clear all data (useful for testing)
  static Future<void> clearAllData() async {
    _serviceRequests.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
