import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../home/controllers/shell_controller.dart';
import '../controllers/chat_controller.dart';

class ChatRoomView extends StatefulWidget {
  const ChatRoomView({super.key, required this.roomId});

  final String roomId;

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  final _messageCtrl = TextEditingController();
  Timer? _typingTimer;

  @override
  void dispose() {
    _typingTimer?.cancel();
    final controller = Get.find<ChatController>();
    final shell = Get.find<ShellController>();
    final userId = shell.user.value?.id;
    if (userId != null) {
      controller.setTyping(widget.roomId, userId, false);
    }
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final shell = Get.find<ShellController>();
    final userRepo = Get.find<UserRepository>();
    final authRepo = Get.find<AuthRepository>();
    final userId = shell.user.value?.id ?? '';
    final authUid = authRepo.currentUser?.uid ?? '';

    // Debug: Check if userId matches authenticated UID
    if (userId.isNotEmpty && authUid.isNotEmpty && userId != authUid) {
      debugPrint(
        '⚠️  WARNING: User profile ID ($userId) != Firebase Auth UID ($authUid)',
      );
    } else if (userId.isNotEmpty && authUid.isNotEmpty) {
      debugPrint('✅ User profile ID matches Firebase Auth UID: $userId');
    }

    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder(
          stream: controller.room(widget.roomId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Chat');
            final room = snapshot.data!;
            final otherId = room.participantIds.firstWhere(
              (id) => id != userId,
              orElse: () => '',
            );
            if (otherId.isEmpty) return const Text('Chat');
            return FutureBuilder<AppUser>(
              future: userRepo.fetchUser(otherId),
              builder: (context, snap) {
                final name = snap.data?.displayName;
                return Text((name?.isNotEmpty ?? false) ? name! : 'Chat');
              },
            );
          },
        ),
      ),
      body: Column(
        children: [
          StreamBuilder(
            stream: controller.room(widget.roomId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              final room = snapshot.data!;
              final someoneTyping = room.typing.entries.any(
                (entry) => entry.key != userId && entry.value,
              );
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: someoneTyping ? 32 : 0,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  someoneTyping ? 'Typing…' : '',
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              );
            },
          ),
          Expanded(
            child: StreamBuilder(
              stream: controller.messages(widget.roomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMine = message.senderId == userId;
                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMine
                              ? Colors.blueAccent.withOpacity(0.9)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: message.type == 'image'
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  message.content,
                                  width: 220,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const SizedBox(
                                    width: 220,
                                    height: 160,
                                    child: Center(
                                      child: Text('Image unavailable'),
                                    ),
                                  ),
                                ),
                              )
                            : Text(
                                message.content,
                                style: TextStyle(
                                  color: isMine ? Colors.white : Colors.black87,
                                ),
                              ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      onChanged: (_) {
                        if (userId.isEmpty) return;
                        controller.setTyping(widget.roomId, userId, true);
                        _typingTimer?.cancel();
                        _typingTimer = Timer(const Duration(seconds: 2), () {
                          controller.setTyping(widget.roomId, userId, false);
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        filled: true,
                      ),
                    ),
                  ),
                  Obx(
                    () => IconButton(
                      icon: controller.isUploadingImage.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo),
                      onPressed: controller.isUploadingImage.value
                          ? null
                          : () => controller.sendImage(
                              roomId: widget.roomId,
                              senderId: userId,
                            ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final text = _messageCtrl.text.trim();
                      if (text.isEmpty) return;
                      controller.sendMessage(
                        roomId: widget.roomId,
                        senderId: userId,
                        content: text,
                      );
                      _messageCtrl.clear();
                      if (userId.isNotEmpty) {
                        controller.setTyping(widget.roomId, userId, false);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
