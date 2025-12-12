import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_constants.dart';
import '../models/chat_message.dart';
import '../models/chat_room.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<ChatRoom> createRoom(
    String bookingId,
    List<String> participants,
  ) async {
    final ref = _firestore.collection(AppConstants.chatsCollection).doc();
    final now = DateTime.now();
    final room = ChatRoom(
      id: ref.id,
      bookingId: bookingId,
      participantIds: participants,
      lastMessage: '',
      updatedAt: now,
    );
    await ref.set({
      'bookingId': bookingId,
      'participantIds': participants,
      'lastMessage': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return room;
  }

  Future<ChatRoom> ensureRoom(
    String bookingId,
    List<String> participants,
  ) async {
    final existing = await _firestore
        .collection(AppConstants.chatsCollection)
        .where('bookingId', isEqualTo: bookingId)
        .limit(1)
        .get();
    if (existing.docs.isNotEmpty) {
      final doc = existing.docs.first;
      return ChatRoom.fromMap(doc.id, doc.data());
    }
    return createRoom(bookingId, participants);
  }

  Stream<List<ChatRoom>> watchRooms(String userId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .where('participantIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => ChatRoom.fromMap(d.id, d.data())).toList(),
        );
  }

  Stream<List<ChatMessage>> watchMessages(String roomId) {
    return _firestore
        .collection(AppConstants.chatsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesCollection)
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatMessage.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> sendMessage(String roomId, ChatMessage message) async {
    final ref = _firestore
        .collection(AppConstants.chatsCollection)
        .doc(roomId)
        .collection(AppConstants.messagesCollection)
        .doc(message.id);
    await ref.set({
      'senderId': message.senderId,
      'content': message.content,
      'type': message.type,
      'sentAt': FieldValue.serverTimestamp(),
    });
    await _firestore
        .collection(AppConstants.chatsCollection)
        .doc(roomId)
        .update({
          'lastMessage': message.content,
          'updatedAt': FieldValue.serverTimestamp(),
        });
  }
}
