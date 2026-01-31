import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/service_request.dart';
import '../services/service_request_service.dart';
import '../services/auth_service.dart';

class CreateServiceRequestScreen extends StatefulWidget {
  final ServiceRequest? existingRequest;
  
  const CreateServiceRequestScreen({super.key, this.existingRequest});

  @override
  State<CreateServiceRequestScreen> createState() =>
      _CreateServiceRequestScreenState();
}

class _CreateServiceRequestScreenState
    extends State<CreateServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  DateTime? _expectedStartDate;
  DateTime? _expectedEndDate;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRequest != null) {
      _isEditMode = true;
      _locationController.text = widget.existingRequest!.location;
      _descriptionController.text = widget.existingRequest!.serviceDescription;
      _expectedStartDate = widget.existingRequest!.expectedStartDate;
      _expectedEndDate = widget.existingRequest!.expectedEndDate;
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expectedStartDate = picked;
        // Reset end date if it's before start date
        if (_expectedEndDate != null && _expectedEndDate!.isBefore(picked)) {
          _expectedEndDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime firstDate = _expectedStartDate ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expectedEndDate ?? firstDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _expectedEndDate = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_expectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expected start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_expectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an expected end date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final currentUser = AuthService.currentUser;
    
    Map<String, dynamic> result;
    
    if (_isEditMode && widget.existingRequest != null) {
      // Update existing request
      final updatedRequest = widget.existingRequest!.copyWith(
        expectedStartDate: _expectedStartDate,
        expectedEndDate: _expectedEndDate,
        location: _locationController.text.trim(),
        serviceDescription: _descriptionController.text.trim(),
      );
      
      // Delete old and add updated (simpler than implementing update separately)
      await ServiceRequestService.deleteRequest(widget.existingRequest!.id);
      result = await ServiceRequestService.addRequest(updatedRequest);
    } else {
      // Create new request
      final request = ServiceRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientEmail: currentUser?.email ?? '',
        expectedStartDate: _expectedStartDate!,
        expectedEndDate: _expectedEndDate!,
        location: _locationController.text.trim(),
        serviceDescription: _descriptionController.text.trim(),
        createdAt: DateTime.now(),
      );
      
      result = await ServiceRequestService.addRequest(request);
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode 
              ? 'Service request updated successfully!' 
              : 'Service request submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Service Request' : 'Create Service Request'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32 : 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Expected Start Date
                Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: _selectStartDate,
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expected Start Date',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _expectedStartDate != null
                                      ? dateFormat.format(_expectedStartDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: _expectedStartDate != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _expectedStartDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Expected End Date
                Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: _selectEndDate,
                    child: Padding(
                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.event,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Expected End Date',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _expectedEndDate != null
                                      ? dateFormat.format(_expectedEndDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: _expectedEndDate != null
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: _expectedEndDate != null
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Location
                TextFormField(
                  controller: _locationController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter service location address',
                    prefixIcon: const Icon(Icons.location_on),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Service Description
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Service Description',
                    hintText: 'Describe the service you are requesting...',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 80),
                      child: Icon(Icons.description),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a service description';
                    }
                    if (value.trim().length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Submit Button
                SizedBox(
                  height: isTablet ? 56 : 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isEditMode ? 'Update Request' : 'Submit Request',
                            style: TextStyle(
                              fontSize: isTablet ? 18 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                // Cancel Button
                SizedBox(
                  height: isTablet ? 56 : 48,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleCancel,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
