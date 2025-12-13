import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/app_constants.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
    : _rooms = (firestore ?? FirebaseFirestore.instance).collection(
        AppConstants.chatsCollection,
      ),
      _messagesRoot = (firestore ?? FirebaseFirestore.instance).collection(
        AppConstants.messagesCollection,
      );

  final CollectionReference<Map<String, dynamic>> _rooms;
  final CollectionReference<Map<String, dynamic>> _messagesRoot;

  Future<ChatRoom> createRoom(
    String bookingId,
    List<String> participants,
  ) async {
    final ref = _rooms.doc();
    final now = DateTime.now();
    final room = ChatRoom(
      id: ref.id,
      bookingId: bookingId,
      participantIds: participants,
      lastMessage: '',
      lastMessageType: 'text',
      updatedAt: now,
      typing: const {},
    );
    await ref.set({
      'bookingId': bookingId,
      'participantIds': participants,
      'lastMessage': '',
      'lastMessageType': 'text',
      'updatedAt': FieldValue.serverTimestamp(),
      'typing': {},
    });
    return room;
  }

  Future<ChatRoom> ensureRoom(
    String bookingId,
    List<String> participants,
  ) async {
    if (participants.isEmpty) return createRoom(bookingId, participants);
    final primary = participants.first;
    final snap = await _rooms
        .where('participantIds', arrayContains: primary)
        .get();

    for (final doc in snap.docs) {
      final ids = List<String>.from(doc.data()['participantIds'] ?? []);
      if (_sameParticipants(ids, participants)) {
        return ChatRoom.fromMap(doc.id, doc.data());
      }
    }

    return createRoom(bookingId, participants);
  }

  Stream<List<ChatRoom>> watchRooms(String userId) {
    return _rooms
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ChatRoom.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<ChatRoom> watchRoom(String roomId) {
    return _rooms.doc(roomId).snapshots().map((snap) {
      return ChatRoom.fromMap(snap.id, snap.data() ?? {});
    });
  }

  Stream<List<ChatMessage>> watchMessages(String roomId) {
    return _messagesRoot
        .doc(roomId)
        .collection(AppConstants.messagesSubCollection)
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatMessage.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> sendMessage(String roomId, ChatMessage message) async {
    // Verify sender is a participant before attempting write
    final roomSnap = await _rooms.doc(roomId).get();
    if (!roomSnap.exists) {
      throw Exception('Chat room not found: $roomId');
    }
    final participants = List<String>.from(
      roomSnap.data()?['participantIds'] ?? [],
    );
    debugPrint('✅ Room $roomId participants: $participants');
    debugPrint('✅ Message senderId: ${message.senderId}');
    if (!participants.contains(message.senderId)) {
      throw Exception(
        'Sender ${message.senderId} is not a participant. Room has: $participants',
      );
    }
    debugPrint(
      '✅ Sender validated as participant, proceeding with Firestore write...',
    );

    final ref = _messagesRoot
        .doc(roomId)
        .collection(AppConstants.messagesSubCollection)
        .doc(message.id);
    await ref.set({
      'senderId': message.senderId,
      'content': message.content,
      'type': message.type,
      'sentAt': FieldValue.serverTimestamp(),
    });

    await _rooms.doc(roomId).set({
      'lastMessage': message.type == 'image' ? '[Image]' : message.content,
      'lastMessageType': message.type,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setTyping(String roomId, String userId, bool isTyping) async {
    await _rooms.doc(roomId).set({
      'typing': {userId: isTyping},
    }, SetOptions(merge: true));
  }

  Future<ChatRoom?> fetchRoom(String roomId) async {
    final snap = await _rooms.doc(roomId).get();
    if (!snap.exists) return null;
    return ChatRoom.fromMap(snap.id, snap.data() ?? {});
  }

  bool _sameParticipants(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sa = a.toSet();
    final sb = b.toSet();
    return sa.length == sb.length && sa.containsAll(sb);
  }
}
