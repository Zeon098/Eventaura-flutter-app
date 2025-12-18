import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../controllers/chat_controller.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.roomId,
    required this.userId,
    required this.userRepo,
  });

  final String roomId;
  final String userId;
  final UserRepository userRepo;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppTheme.textPrimaryColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: StreamBuilder(
        stream: controller.room(roomId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Text('Chat', style: TextStyle(color: Colors.black));
          }
          final room = snapshot.data!;
          final otherId = room.participantIds.firstWhere(
            (id) => id != userId,
            orElse: () => '',
          );
          if (otherId.isEmpty) {
            return const Text('Chat', style: TextStyle(color: Colors.black));
          }
          return FutureBuilder<AppUser>(
            future: userRepo.fetchUser(otherId),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Text(
                  'Chat',
                  style: TextStyle(color: Colors.black),
                );
              }
              final user = snap.data!;
              final photoUrl = user.photoUrl;
              return Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: photoUrl == null || photoUrl.isEmpty
                          ? LinearGradient(
                              colors: [AppTheme.accent, AppTheme.accent],
                            )
                          : null,
                      shape: BoxShape.circle,
                    ),
                    child: photoUrl != null && photoUrl.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              width: 40,
                              height: 40,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  (user.displayName ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              (user.displayName ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName ?? 'User',
                          style: TextStyle(
                            color: AppTheme.textPrimaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        StreamBuilder(
                          stream: controller.room(roomId),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            final room = snapshot.data!;
                            final isTyping = room.typing[otherId] == true;
                            return Text(
                              isTyping ? 'typing...' : 'Online',
                              style: TextStyle(
                                color: isTyping
                                    ? AppTheme.primaryColor
                                    : AppTheme.successColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
