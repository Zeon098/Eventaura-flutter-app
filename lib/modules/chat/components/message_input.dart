import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/chat_controller.dart';

class MessageInput extends StatefulWidget {
  const MessageInput({super.key, required this.roomId, required this.userId});

  final String roomId;
  final String userId;

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _messageCtrl = TextEditingController();
  Timer? _typingTimer;

  @override
  void dispose() {
    _typingTimer?.cancel();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Obx(
                () => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accent],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: controller.isUploadingImage.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.photo, color: Colors.white),
                    onPressed: controller.isUploadingImage.value
                        ? null
                        : () => controller.sendImage(
                            roomId: widget.roomId,
                            senderId: widget.userId,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageCtrl,
                    onChanged: (_) {
                      if (widget.userId.isEmpty) return;
                      controller.setTyping(widget.roomId, widget.userId, true);
                      _typingTimer?.cancel();
                      _typingTimer = Timer(const Duration(seconds: 2), () {
                        controller.setTyping(
                          widget.roomId,
                          widget.userId,
                          false,
                        );
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: AppTheme.textSecondaryColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    final text = _messageCtrl.text.trim();
                    if (text.isEmpty) return;
                    controller.sendMessage(
                      roomId: widget.roomId,
                      senderId: widget.userId,
                      content: text,
                    );
                    _messageCtrl.clear();
                    if (widget.userId.isNotEmpty) {
                      controller.setTyping(widget.roomId, widget.userId, false);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
