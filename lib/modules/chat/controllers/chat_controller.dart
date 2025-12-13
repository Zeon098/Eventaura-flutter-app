import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/firebase/push_notification_service.dart';
import '../../../core/stores/user_store.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/chat_room.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/user_repository.dart';

class ChatController extends GetxController {
  ChatController({
    required this.chatRepository,
    required this.cloudinaryService,
    required this.userRepository,
    required this.userStore,
    required this.pushNotificationService,
  });

  final ChatRepository chatRepository;
  final CloudinaryService cloudinaryService;
  final UserRepository userRepository;
  final UserStore userStore;
  final PushNotificationService pushNotificationService;
  final _uuid = const Uuid();
  final isSending = false.obs;
  final isUploadingImage = false.obs;
  final picker = ImagePicker();

  Stream<List<ChatRoom>> rooms(String userId) =>
      chatRepository.watchRooms(userId);

  Stream<List<ChatMessage>> messages(String roomId) =>
      chatRepository.watchMessages(roomId);

  Stream<ChatRoom> room(String roomId) => chatRepository.watchRoom(roomId);

  Future<ChatRoom> ensureRoom(String bookingId, List<String> participants) =>
      chatRepository.ensureRoom(bookingId, participants);

  Future<void> sendMessage({
    required String roomId,
    required String senderId,
    required String content,
  }) async {
    if (content.isEmpty) return;
    final message = ChatMessage(
      id: _uuid.v4(),
      senderId: senderId,
      content: content,
      type: 'text',
      sentAt: DateTime.now(),
    );
    await _deliverMessage(roomId, message);
  }

  Future<void> sendImage({
    required String roomId,
    required String senderId,
  }) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final file = File(picked.path);
    isUploadingImage.value = true;
    try {
      final url = await cloudinaryService.uploadImage(file, folder: 'chat');
      final message = ChatMessage(
        id: _uuid.v4(),
        senderId: senderId,
        content: url,
        type: 'image',
        sentAt: DateTime.now(),
      );
      await _deliverMessage(roomId, message);
    } catch (e) {
      SnackbarUtils.error('Image upload failed', e.toString());
    } finally {
      isUploadingImage.value = false;
    }
  }

  Future<void> _deliverMessage(String roomId, ChatMessage message) async {
    try {
      isSending.value = true;
      debugPrint('💬 Attempting to send message:');
      debugPrint('  Room ID: $roomId');
      debugPrint('  Sender ID: ${message.senderId}');
      debugPrint('  Message type: ${message.type}');
      await chatRepository.sendMessage(roomId, message);
      await _notifyParticipants(roomId, message);
    } catch (e) {
      SnackbarUtils.error('Message failed', e.toString());
      debugPrint('❌ Error sending message: $e');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> _notifyParticipants(String roomId, ChatMessage message) async {
    final room = await chatRepository.fetchRoom(roomId);
    if (room == null) return;
    final sender = userStore.value;
    final title = sender?.displayName?.isNotEmpty == true
        ? '${sender!.displayName} sent a message'
        : 'New message';
    final body = message.type == 'image' ? 'Sent an image' : message.content;

    for (final participantId in room.participantIds) {
      if (participantId == message.senderId) continue;
      AppUser? target;
      try {
        target = await userRepository.fetchUser(participantId);
      } catch (_) {
        continue;
      }
      final token = target.fcmToken;
      if (token == null || token.isEmpty) continue;
      await pushNotificationService.sendPushToToken(
        token: token,
        title: title,
        body: body,
        data: {'type': 'chat', 'roomId': roomId, 'senderId': message.senderId},
      );
    }
  }

  Future<void> setTyping(String roomId, String userId, bool isTyping) =>
      chatRepository.setTyping(roomId, userId, isTyping);
}
