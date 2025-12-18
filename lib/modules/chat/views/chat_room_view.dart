import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../home/controllers/shell_controller.dart';
import '../components/chat_app_bar.dart';
import '../components/message_bubble.dart';
import '../components/message_input.dart';
import '../controllers/chat_controller.dart';

class ChatRoomView extends StatefulWidget {
  const ChatRoomView({super.key, required this.roomId});

  final String roomId;

  @override
  State<ChatRoomView> createState() => _ChatRoomViewState();
}

class _ChatRoomViewState extends State<ChatRoomView> {
  @override
  void dispose() {
    final controller = Get.find<ChatController>();
    final shell = Get.find<ShellController>();
    final userId = shell.user.value?.id;
    if (userId != null) {
      controller.setTyping(widget.roomId, userId, false);
    }
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
      backgroundColor: AppTheme.surfaceColor,
      appBar: ChatAppBar(
        roomId: widget.roomId,
        userId: userId,
        userRepo: userRepo,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: controller.messages(widget.roomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppTheme.textSecondaryColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (_, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMine = message.senderId == userId;
                    final showTime =
                        index == 0 ||
                        (messages.length - 1 - index + 1 < messages.length &&
                            message.sentAt
                                    .difference(
                                      messages[messages.length - 1 - index + 1]
                                          .sentAt,
                                    )
                                    .inMinutes
                                    .abs() >
                                5);
                    return MessageBubble(
                      message: message,
                      isMine: isMine,
                      showTime: showTime,
                    );
                  },
                );
              },
            ),
          ),
          MessageInput(roomId: widget.roomId, userId: userId),
        ],
      ),
    );
  }
}
