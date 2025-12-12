import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();
    final shell = Get.find<ShellController>();
    final userId = shell.user.value?.id ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Chat room')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: controller.messages(widget.roomId),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());
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
                        child: Text(
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
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        filled: true,
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
