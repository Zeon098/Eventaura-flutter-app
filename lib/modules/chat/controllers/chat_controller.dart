import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/models/chat_room.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatController extends GetxController {
  ChatController({required this.chatRepository});

  final ChatRepository chatRepository;
  final _uuid = const Uuid();
  final isSending = false.obs;

  Stream<List<ChatRoom>> rooms(String userId) =>
      chatRepository.watchRooms(userId);

  Stream<List<ChatMessage>> messages(String roomId) =>
      chatRepository.watchMessages(roomId);

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
    try {
      isSending.value = true;
      await chatRepository.sendMessage(roomId, message);
    } catch (e) {
      SnackbarUtils.error('Message failed', e.toString());
    } finally {
      isSending.value = false;
    }
  }
}
