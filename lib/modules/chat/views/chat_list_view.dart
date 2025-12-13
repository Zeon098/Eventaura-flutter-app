import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../home/controllers/shell_controller.dart';
import '../controllers/chat_controller.dart';
import 'chat_room_view.dart';

class ChatListView extends GetView<ChatController> {
  const ChatListView({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    final userRepo = Get.find<UserRepository>();
    final userId = shell.user.value?.id ?? '';
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: StreamBuilder(
        stream: controller.rooms(userId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load chats: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final rooms = snapshot.data!;
          if (rooms.isEmpty)
            return const Center(child: Text('No conversations yet'));
          return ListView.separated(
            itemBuilder: (_, index) {
              final room = rooms[index];
              final preview = room.lastMessageType == 'image'
                  ? '[Image]'
                  : room.lastMessage;
              final otherId = room.participantIds.firstWhere(
                (id) => id != userId,
                orElse: () => '',
              );
              return ListTile(
                title: FutureBuilder<AppUser>(
                  future: otherId.isEmpty ? null : userRepo.fetchUser(otherId),
                  builder: (context, snap) {
                    final name = snap.data?.displayName;
                    if (name != null && name.isNotEmpty) return Text(name);
                    return Text('Chat ${room.id.substring(0, 6)}');
                  },
                ),
                subtitle: Text(preview.isEmpty ? 'No messages yet' : preview),
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
