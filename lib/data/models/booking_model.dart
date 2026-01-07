import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BookingModel extends Equatable {
  static const pending = 'pending';
  static const accepted = 'accepted';
  static const rejected = 'rejected';
  static const completed = 'completed';
  static const cancelled = 'cancelled';

  final String id;
  final String serviceId;
  final String consumerId;
  final String providerId;
  final String? categoryId; // legacy single selection
  final String? categoryName; // legacy single selection
  final double? categoryPrice; // legacy single selection
  final List<String> categoryIds;
  final List<String> categoryNames;
  final double? totalPrice;
  final String dateKey; // yyyy-MM-dd for easy querying by day
  final DateTime startTime;
  final DateTime endTime;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String status; // pending | accepted | rejected | completed | cancelled

  const BookingModel({
    required this.id,
    required this.serviceId,
    required this.consumerId,
    required this.providerId,
    this.categoryId,
    this.categoryName,
    this.categoryPrice,
    this.categoryIds = const [],
    this.categoryNames = const [],
    this.totalPrice,
    required this.dateKey,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    this.updatedAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'consumerId': consumerId,
      'providerId': providerId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryPrice': categoryPrice,
      'categoryIds': categoryIds,
      'categoryNames': categoryNames,
      'totalPrice': totalPrice,
      'date': dateKey,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status': status,
    };
  }

  factory BookingModel.fromMap(String id, Map<String, dynamic> map) {
    return BookingModel(
      id: id,
      serviceId: map['serviceId'],
      consumerId: map['consumerId'],
      providerId: map['providerId'],
      categoryId: map['categoryId'],
      categoryName: map['categoryName'],
      categoryPrice: (map['categoryPrice'] as num?)?.toDouble(),
      categoryIds: List<String>.from(map['categoryIds'] ?? const <String>[]),
      categoryNames: List<String>.from(
        map['categoryNames'] ?? const <String>[],
      ),
      totalPrice: (map['totalPrice'] as num?)?.toDouble(),
      dateKey: map['date'] ?? '',
      startTime: _parseDate(map['startTime']),
      endTime: _parseDate(map['endTime']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDateOrNull(map['updatedAt']),
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

  static DateTime? _parseDateOrNull(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is Timestamp) return value.toDate();
    return null;
  }

  bool get isPending => status == pending;
  bool get isAccepted => status == accepted;
  bool get isRejected => status == rejected;
  bool get isCompleted => status == completed;
  bool get isCancelled => status == cancelled;

  @override
  List<Object?> get props => [
    id,
    serviceId,
    consumerId,
    providerId,
    categoryId,
    categoryName,
    categoryPrice,
    categoryIds,
    categoryNames,
    totalPrice,
    dateKey,
    startTime,
    endTime,
    createdAt,
    updatedAt,
    status,
  ];
}
