import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/shell_controller.dart';
import '../controllers/chat_controller.dart';
import 'chat_room_view.dart';

class ChatListView extends GetView<ChatController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    final userId = shell.user.value?.id ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: StreamBuilder(
        stream: controller.rooms(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final rooms = snapshot.data!;
          if (rooms.isEmpty)
            return const Center(child: Text('No conversations yet'));
          return ListView.separated(
            itemBuilder: (_, index) {
              final room = rooms[index];
              return ListTile(
                title: Text('Chat ${room.id.substring(0, 6)}'),
                subtitle: Text(
                  room.lastMessage.isEmpty
                      ? 'No messages yet'
                      : room.lastMessage,
                ),
                onTap: () => Get.to(() => ChatRoomView(roomId: room.id)),
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: rooms.length,
          );
        },
      ),
    );
  }
}
