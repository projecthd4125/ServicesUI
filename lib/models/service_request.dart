class ServiceRequest {
  final String id;
  final String clientEmail;
  final DateTime expectedStartDate;
  final DateTime expectedEndDate;
  final String location;
  final String serviceDescription;
  final DateTime createdAt;
  final String status; // pending, approved, rejected, completed

  ServiceRequest({
    required this.id,
    required this.clientEmail,
    required this.expectedStartDate,
    required this.expectedEndDate,
    required this.location,
    required this.serviceDescription,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientEmail': clientEmail,
      'expectedStartDate': expectedStartDate.toIso8601String(),
      'expectedEndDate': expectedEndDate.toIso8601String(),
      'location': location,
      'serviceDescription': serviceDescription,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'],
      clientEmail: json['clientEmail'],
      expectedStartDate: DateTime.parse(json['expectedStartDate']),
      expectedEndDate: DateTime.parse(json['expectedEndDate']),
      location: json['location'],
      serviceDescription: json['serviceDescription'],
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] ?? 'pending',
    );
  }

  ServiceRequest copyWith({
    String? id,
    String? clientEmail,
    DateTime? expectedStartDate,
    DateTime? expectedEndDate,
    String? location,
    String? serviceDescription,
    DateTime? createdAt,
    String? status,
  }) {
    return ServiceRequest(
      id: id ?? this.id,
      clientEmail: clientEmail ?? this.clientEmail,
      expectedStartDate: expectedStartDate ?? this.expectedStartDate,
      expectedEndDate: expectedEndDate ?? this.expectedEndDate,
      location: location ?? this.location,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
