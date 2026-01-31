/// Service request status enumeration
enum RequestStatus {
  pending,
  inReview,
  needMoreInfo,
  accepted,
  payment,
  paid,
  paymentReceived,
  assigningProvider,
  providerAssigned,
  approved,
  rejected,
  completed;

  /// Get display name for the status
  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.inReview:
        return 'In Review';
      case RequestStatus.needMoreInfo:
        return 'Need More Information';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.payment:
        return 'Payment';
      case RequestStatus.paid:
        return 'Paid';
      case RequestStatus.paymentReceived:
        return 'Payment Received';
      case RequestStatus.assigningProvider:
        return 'Service Provider Assignment In Progress';
      case RequestStatus.providerAssigned:
        return 'Service Provider Assigned';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.completed:
        return 'Completed';
    }
  }

  /// Get uppercase display name
  String get upperCaseName => displayName.toUpperCase();

  /// Create from string
  static RequestStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return RequestStatus.pending;
      case 'inreview':
      case 'in_review':
        return RequestStatus.inReview;
      case 'needmoreinfo':
      case 'need_more_info':
        return RequestStatus.needMoreInfo;
      case 'accepted':
        return RequestStatus.accepted;
      case 'payment':
        return RequestStatus.payment;
      case 'paid':
        return RequestStatus.paid;
      case 'paymentreceived':
      case 'payment_received':
        return RequestStatus.paymentReceived;
      case 'assigningprovider':
      case 'assigning_provider':
        return RequestStatus.assigningProvider;
      case 'providerassigned':
      case 'provider_assigned':
        return RequestStatus.providerAssigned;
      case 'approved':
        return RequestStatus.approved;
      case 'rejected':
        return RequestStatus.rejected;
      case 'completed':
        return RequestStatus.completed;
      default:
        return RequestStatus.pending;
    }
  }

  /// Convert to string for storage
  String toStorageString() {
    return name;
  }
}

/// Service request model
class ServiceRequest {
  final String id;
  final String clientEmail;
  final DateTime expectedStartDate;
  final DateTime expectedEndDate;
  final String location;
  final String serviceDescription;
  final String countryCode;
  final String contactNumber;
  final DateTime createdAt;
  final RequestStatus status;
  final String? adminMessage;
  final String? clientResponse;
  final DateTime? responseDate;
  final String? paymentInfo;
  final DateTime? paymentInfoDate;
  final String? assignedProviderEmail;
  final DateTime? providerAssignedDate;

  const ServiceRequest({
    required this.id,
    required this.clientEmail,
    required this.expectedStartDate,
    required this.expectedEndDate,
    required this.location,
    required this.serviceDescription,
    required this.countryCode,
    required this.contactNumber,
    required this.createdAt,
    this.status = RequestStatus.pending,
    this.adminMessage,
    this.clientResponse,
    this.responseDate,
    this.paymentInfo,
    this.paymentInfoDate,
    this.assignedProviderEmail,
    this.providerAssignedDate,
  });

  /// Get formatted phone number
  String get formattedPhoneNumber => '$countryCode $contactNumber';

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientEmail': clientEmail,
      'expectedStartDate': expectedStartDate.toIso8601String(),
      'expectedEndDate': expectedEndDate.toIso8601String(),
      'location': location,
      'serviceDescription': serviceDescription,
      'countryCode': countryCode,
      'contactNumber': contactNumber,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toStorageString(),
      'adminMessage': adminMessage,
      'clientResponse': clientResponse,
      'responseDate': responseDate?.toIso8601String(),
      'paymentInfo': paymentInfo,
      'paymentInfoDate': paymentInfoDate?.toIso8601String(),
      'assignedProviderEmail': assignedProviderEmail,
      'providerAssignedDate': providerAssignedDate?.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      clientEmail: json['clientEmail'] as String,
      expectedStartDate: DateTime.parse(json['expectedStartDate'] as String),
      expectedEndDate: DateTime.parse(json['expectedEndDate'] as String),
      location: json['location'] as String,
      serviceDescription: json['serviceDescription'] as String,
      countryCode: json['countryCode'] as String? ?? '+1',
      contactNumber: json['contactNumber'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      status: RequestStatus.fromString(json['status'] as String? ?? 'pending'),
      adminMessage: json['adminMessage'] as String?,
      clientResponse: json['clientResponse'] as String?,
      responseDate: json['responseDate'] != null 
          ? DateTime.parse(json['responseDate'] as String)
          : null,
      paymentInfo: json['paymentInfo'] as String?,
      paymentInfoDate: json['paymentInfoDate'] != null
          ? DateTime.parse(json['paymentInfoDate'] as String)
          : null,
      assignedProviderEmail: json['assignedProviderEmail'] as String?,
      providerAssignedDate: json['providerAssignedDate'] != null
          ? DateTime.parse(json['providerAssignedDate'] as String)
          : null,
    );
  }

  /// Create a copy with updated fields
  ServiceRequest copyWith({
    String? id,
    String? clientEmail,
    DateTime? expectedStartDate,
    DateTime? expectedEndDate,
    String? location,
    String? serviceDescription,
    String? countryCode,
    String? contactNumber,
    DateTime? createdAt,
    RequestStatus? status,
    String? adminMessage,
    String? clientResponse,
    DateTime? responseDate,
    String? paymentInfo,
    DateTime? paymentInfoDate,
    String? assignedProviderEmail,
    DateTime? providerAssignedDate,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      clientEmail: clientEmail ?? this.clientEmail,
      expectedStartDate: expectedStartDate ?? this.expectedStartDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      location: location ?? this.location,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      countryCode: countryCode ?? this.countryCode,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      adminMessage: adminMessage ?? this.adminMessage,
      clientResponse: clientResponse ?? this.clientResponse,
      responseDate: responseDate ?? this.responseDate,
      paymentInfo: paymentInfo ?? this.paymentInfo,
      paymentInfoDate: paymentInfoDate ?? this.paymentInfoDate,
      assignedProviderEmail: assignedProviderEmail ?? this.assignedProviderEmail,
      providerAssignedDate: providerAssignedDate ?? this.providerAssignedDate,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ServiceRequest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ServiceRequest(id: $id, client: $clientEmail, status: ${status.displayName})';
  }
}
