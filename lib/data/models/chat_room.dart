import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final String bookingId;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime updatedAt;

  const ChatRoom({
    required this.id,
    required this.bookingId,
    required this.participantIds,
    required this.lastMessage,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ChatRoom.fromMap(String id, Map<String, dynamic> map) {
    return ChatRoom(
      id: id,
      bookingId: map['bookingId'],
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      updatedAt: _parseDate(map['updatedAt']),
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
    bookingId,
    participantIds,
    lastMessage,
    updatedAt,
  ];
}
