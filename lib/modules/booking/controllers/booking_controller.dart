import 'package:get/get.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/chat_repository.dart';

class BookingController extends GetxController {
  BookingController({
    required this.bookingRepository,
    required this.chatRepository,
  });

  final BookingRepository bookingRepository;
  final ChatRepository chatRepository;
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
  }) async {
    try {
      isLoading.value = true;
      final booking = await bookingRepository.createBooking(
        serviceId: serviceId,
        consumerId: consumerId,
        providerId: providerId,
      );
      await chatRepository.ensureRoom(booking.id, [consumerId, providerId]);
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
}
