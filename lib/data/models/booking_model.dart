import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  final String id;
  final String serviceId;
  final String consumerId;
  final String providerId;
  final DateTime createdAt;
  final String status; // pending | accepted | rejected | completed

  const BookingModel({
    required this.id,
    required this.serviceId,
    required this.consumerId,
    required this.providerId,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'consumerId': consumerId,
      'providerId': providerId,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      serviceId: map['serviceId'],
      consumerId: map['consumerId'],
      providerId: map['providerId'],
      createdAt: _parseDate(map['createdAt']),
      status: map['status'] ?? 'pending',
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }

  @override
  List<Object?> get props => [
    id,
    serviceId,
    consumerId,
    providerId,
    createdAt,
    status,
  ];
}
