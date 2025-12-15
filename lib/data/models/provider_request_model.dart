import 'package:cloud_firestore/cloud_firestore.dart';

class ProviderRequest {
  final String id;
  final String userId;
  final String businessName;
  final String description;
  final String cnicFrontUrl;
  final String cnicBackUrl;
  final String status;
  final String? rejectionReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProviderRequest({
    required this.id,
    required this.userId,
    required this.businessName,
    required this.description,
    required this.cnicFrontUrl,
    required this.cnicBackUrl,
    this.status = 'pending',
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'businessName': businessName,
      'description': description,
      'cnicFrontUrl': cnicFrontUrl,
      'cnicBackUrl': cnicBackUrl,
      'status': status,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ProviderRequest.fromMap(Map<String, dynamic> map) {
    return ProviderRequest(
      id: map['id'] ?? map['userId'],
      userId: map['userId'],
      businessName: map['businessName'],
      description: map['description'],
      cnicFrontUrl: map['cnicFrontUrl'],
      cnicBackUrl: map['cnicBackUrl'],
      status: map['status'] ?? 'pending',
      rejectionReason: map['rejectionReason'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
