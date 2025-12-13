import 'package:get/get.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/services/firebase/push_notification_service.dart';

class BookingController extends GetxController {
  BookingController({
    required this.bookingRepository,
    required this.chatRepository,
    required this.userRepository,
    required this.pushNotificationService,
  });

  final BookingRepository bookingRepository;
  final ChatRepository chatRepository;
  final UserRepository userRepository;
  final PushNotificationService pushNotificationService;
  final bookings = <BookingModel>[].obs;
  final isLoading = false.obs;

  Stream<List<BookingModel>> watchConsumer(String userId) =>
      bookingRepository.watchUserBookings(userId);
  Stream<List<BookingModel>> watchProvider(String providerId) =>
      bookingRepository.watchProviderBookings(providerId);

  Future<BookingModel?> createBooking({
    required String serviceId,
    required String consumerId,
    required String providerId,
    String? serviceTitle,
  }) async {
    try {
      isLoading.value = true;
      final booking = await bookingRepository.createBooking(
        serviceId: serviceId,
        consumerId: consumerId,
        providerId: providerId,
      );
      await chatRepository.ensureRoom(booking.id, [consumerId, providerId]);
      await _notifyProvider(
        providerId: providerId,
        serviceTitle: serviceTitle ?? 'New booking',
        bookingId: booking.id,
      );
      SnackbarUtils.success('Booking created', 'Provider will respond soon');
      return booking;
    } catch (e) {
      SnackbarUtils.error('Booking failed', e.toString());
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await bookingRepository.updateStatus(id, status);
      SnackbarUtils.success('Booking', 'Status updated to $status');
    } catch (e) {
      SnackbarUtils.error('Booking', e.toString());
    }
  }

  Future<void> _notifyProvider({
    required String providerId,
    required String serviceTitle,
    required String bookingId,
  }) async {
    try {
      final provider = await userRepository.fetchUser(providerId);
      final token = provider.fcmToken;
      if (token == null || token.isEmpty) return;
      await pushNotificationService.sendPushToToken(
        token: token,
        title: 'New booking request',
        body: 'Someone requested "$serviceTitle"',
        data: {
          'type': 'booking',
          'bookingId': bookingId,
          'providerId': providerId,
        },
      );
    } catch (_) {
      // Ignore push failures to keep booking flow resilient.
    }
  }
}
