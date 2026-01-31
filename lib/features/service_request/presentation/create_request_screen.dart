import 'package:flutter/material.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../auth/data/auth_service.dart';
import '../data/service_request_model.dart';
import '../data/service_request_service.dart';
import 'widgets/date_selector.dart';
import 'widgets/phone_number_field.dart';

/// Screen for creating or editing a service request
class CreateRequestScreen extends StatefulWidget {
  final ServiceRequest? existingRequest;

  const CreateRequestScreen({super.key, this.existingRequest});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _expectedStartDate;
  DateTime? _expectedEndDate;
  String _countryCode = '+1';
  String _phoneNumber = '';
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingRequest != null) {
      _initializeWithExistingRequest();
    }
  }

  void _initializeWithExistingRequest() {
    _isEditMode = true;
    _locationController.text = widget.existingRequest!.location;
    _descriptionController.text = widget.existingRequest!.serviceDescription;
    _expectedStartDate = widget.existingRequest!.expectedStartDate;
    _expectedEndDate = widget.existingRequest!.expectedEndDate;
    _countryCode = widget.existingRequest!.countryCode;
    _phoneNumber = widget.existingRequest!.contactNumber;
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    final result = _isEditMode
        ? await _updateExistingRequest()
        : await _createNewRequest();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success) {
      _showSuccessMessage(result.message);
      Navigator.of(context).pop(true);
    } else {
      _showErrorMessage(result.message);
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_expectedStartDate == null) {
      _showErrorMessage('Please select an expected start date');
      return false;
    }

    if (_expectedEndDate == null) {
      _showErrorMessage('Please select an expected end date');
      return false;
    }

    return true;
  }

  Future<ServiceRequestResult> _createNewRequest() async {
    final currentUser = AuthService.currentUser;
    final request = ServiceRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientEmail: currentUser?.email ?? '',
      expectedStartDate: _expectedStartDate!,
      expectedEndDate: _expectedEndDate!,
      location: _locationController.text.trim(),
      serviceDescription: _descriptionController.text.trim(),
      countryCode: _countryCode,
      contactNumber: _phoneNumber,
      createdAt: DateTime.now(),
    );

    return await ServiceRequestService.addRequest(request);
  }

  Future<ServiceRequestResult> _updateExistingRequest() async {
    final updatedRequest = widget.existingRequest!.copyWith(
      expectedStartDate: _expectedStartDate,
      expectedEndDate: _expectedEndDate,
      location: _locationController.text.trim(),
      serviceDescription: _descriptionController.text.trim(),
      countryCode: _countryCode,
      contactNumber: _phoneNumber,
    );

    // Delete old and add updated
    await ServiceRequestService.deleteRequest(widget.existingRequest!.id);
    return await ServiceRequestService.addRequest(updatedRequest);
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorMessage(String message) {
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
        title: Text(_isEditMode ? 'Edit Service Request' : 'Create Service Request'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DateSelector(
                  label: 'Expected Start Date',
                  selectedDate: _expectedStartDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateSelected: (date) {
                    setState(() {
                      _expectedStartDate = date;
                      if (_expectedEndDate != null &&
                          _expectedEndDate!.isBefore(date)) {
                        _expectedEndDate = null;
                      }
                    });
                  },
                  isTablet: isTablet,
                ),
                const SizedBox(height: 16),
                DateSelector(
                  label: 'Expected End Date',
                  selectedDate: _expectedEndDate,
                  firstDate: _expectedStartDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  onDateSelected: (date) {
                    setState(() => _expectedEndDate = date);
                  },
                  isTablet: isTablet,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    hintText: 'Enter service location address',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                PhoneNumberField(
                  selectedCountryCode: _countryCode,
                  phoneNumber: _phoneNumber,
                  onCountryCodeChanged: (code) {
                    setState(() => _countryCode = code);
                  },
                  onPhoneNumberChanged: (number) {
                    setState(() => _phoneNumber = number);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Service Description',
                    hintText: 'Describe the service you are requesting...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 80),
                      child: Icon(Icons.description),
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
                SizedBox(
                  height: isTablet ? 56 : 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
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
                SizedBox(
                  height: isTablet ? 56 : 48,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _handleCancel,
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
