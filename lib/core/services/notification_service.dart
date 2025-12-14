import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/user_repository.dart';
import 'firebase/push_notification_service.dart';

/// Centralized notification service for all push notification logic.
/// Handles notifications for bookings, provider approvals, and chat messages.
class NotificationService extends GetxService {
  NotificationService({
    required this.pushNotificationService,
    required this.userRepository,
  });

  final PushNotificationService pushNotificationService;
  final UserRepository userRepository;

  /// Send notification when provider request is approved/rejected
  Future<void> notifyProviderApproval({
    required String userId,
    required bool approved,
  }) async {
    try {
      final user = await userRepository.fetchUser(userId);
      final token = user.fcmToken;
      if (token == null || token.isEmpty) return;

      await pushNotificationService.sendPushToToken(
        token: token,
        title: approved ? 'Provider Request Approved! 🎉' : 'Provider Request',
        body: approved
            ? 'Congratulations! You can now create services.'
            : 'Your provider request has been reviewed.',
        data: {
          'type': 'provider_approval',
          'approved': approved.toString(),
          'userId': userId,
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to send provider approval notification: $e');
    }
  }

  /// Send notification when a new booking request is received
  Future<void> notifyNewBooking({
    required String providerId,
    required String bookingId,
    required String serviceTitle,
    String? consumerName,
  }) async {
    try {
      final provider = await userRepository.fetchUser(providerId);
      final token = provider.fcmToken;
      if (token == null || token.isEmpty) return;

      final senderName = consumerName ?? 'Someone';
      await pushNotificationService.sendPushToToken(
        token: token,
        title: 'New Booking Request',
        body: '$senderName requested "$serviceTitle"',
        data: {
          'type': 'booking_new',
          'bookingId': bookingId,
          'providerId': providerId,
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to send new booking notification: $e');
    }
  }

  /// Send notification when booking status changes (accepted/rejected)
  Future<void> notifyBookingStatusChange({
    required BookingModel booking,
    required String status,
    String? providerName,
  }) async {
    try {
      final consumer = await userRepository.fetchUser(booking.consumerId);
      final token = consumer.fcmToken;
      if (token == null || token.isEmpty) return;

      final providerLabel = providerName ?? 'Provider';
      final title = status == 'accepted'
          ? 'Booking Accepted ✅'
          : status == 'rejected'
          ? 'Booking Update'
          : 'Booking Status Changed';
      final body = status == 'accepted'
          ? '$providerLabel accepted your booking request!'
          : status == 'rejected'
          ? '$providerLabel declined your booking request.'
          : '$providerLabel updated your booking to $status.';

      await pushNotificationService.sendPushToToken(
        token: token,
        title: title,
        body: body,
        data: {
          'type': 'booking_status',
          'bookingId': booking.id,
          'status': status,
          'consumerId': booking.consumerId,
        },
      );
    } catch (e) {
      debugPrint('❌ Failed to send booking status notification: $e');
    }
  }

  /// Send notification for new chat message
  Future<void> notifyNewMessage({
    required String recipientId,
    required String roomId,
    required String senderId,
    required String messageType,
    String? messageContent,
    String? senderName,
  }) async {
    try {
      final recipient = await userRepository.fetchUser(recipientId);
      final token = recipient.fcmToken;
      if (token == null || token.isEmpty) return;

      final sender = senderName ?? 'Someone';
      final body = messageType == 'image'
          ? '$sender sent an image'
          : messageContent ?? 'New message';

      await pushNotificationService.sendPushToToken(
        token: token,
        title: '$sender sent a message',
        body: body,
        data: {'type': 'chat', 'roomId': roomId, 'senderId': senderId},
      );
    } catch (e) {
      debugPrint('❌ Failed to send chat notification: $e');
    }
  }

  /// Batch notify multiple participants (e.g., chat room participants)
  Future<void> notifyMultipleUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    for (final userId in userIds) {
      try {
        final user = await userRepository.fetchUser(userId);
        final token = user.fcmToken;
        if (token == null || token.isEmpty) continue;

        await pushNotificationService.sendPushToToken(
          token: token,
          title: title,
          body: body,
          data: data,
        );
      } catch (e) {
        debugPrint('❌ Failed to notify user $userId: $e');
      }
    }
  }
}
