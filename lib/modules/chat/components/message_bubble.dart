import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
    required this.showTime,
  });

  final ChatMessage message;
  final bool isMine;
  final bool showTime;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isMine
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isMine
                  ? LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isMine ? null : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isMine ? 20 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: isMine
                      ? AppTheme.primaryColor.withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: message.type == 'image'
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      message.content,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.broken_image_outlined,
                              color: isMine
                                  ? Colors.white
                                  : AppTheme.textSecondaryColor,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Image unavailable',
                              style: TextStyle(
                                color: isMine
                                    ? Colors.white
                                    : AppTheme.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Text(
                    message.content,
                    style: TextStyle(
                      color: isMine ? Colors.white : AppTheme.textPrimaryColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
          ),
        ),
        if (showTime)
          Padding(
            padding: EdgeInsets.only(
              left: isMine ? 0 : 8,
              right: isMine ? 8 : 0,
              bottom: 12,
            ),
            child: Text(
              DateFormat('h:mm a').format(message.sentAt),
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryColor.withOpacity(0.7),
              ),
            ),
          ),
      ],
    );
  }
}
