import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final String bookingId;
  final List<String> participantIds;
  final String lastMessage;
  final String lastMessageType; // text | image
  final DateTime updatedAt;
  final Map<String, bool> typing;

  const ChatRoom({
    required this.id,
    required this.bookingId,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageType,
    required this.updatedAt,
    this.typing = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageType': lastMessageType,
      'updatedAt': updatedAt.toIso8601String(),
      'typing': typing,
    };
  }

  factory ChatRoom.fromMap(String id, Map<String, dynamic> map) {
    return ChatRoom(
      id: id,
      bookingId: map['bookingId'],
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageType: map['lastMessageType'] ?? 'text',
      updatedAt: _parseDate(map['updatedAt']),
      typing: _parseTyping(map['typing']),
    );
  }

  static Map<String, bool> _parseTyping(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, val) => MapEntry(key, val == true));
    }
    return const {};
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
    lastMessageType,
    updatedAt,
    typing,
  ];
}
