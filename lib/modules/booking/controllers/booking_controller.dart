import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart' as rxdart;
import '../../../core/services/notification_service.dart';
import '../../../core/stores/user_store.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/user_repository.dart';

enum BookingDirection { incoming, outgoing }

class BookingWithDirection {
  final BookingModel booking;
  final BookingDirection direction;

  BookingWithDirection(this.booking, this.direction);
}

class BookingController extends GetxController {
  BookingController({
    required this.bookingRepository,
    required this.chatRepository,
    required this.userRepository,
    required this.notificationService,
    required this.userStore,
  });

  final BookingRepository bookingRepository;
  final ChatRepository chatRepository;
  final UserRepository userRepository;
  final NotificationService notificationService;
  final UserStore userStore;
  final bookings = <BookingModel>[].obs;
  final isLoading = false.obs;

  Stream<List<BookingModel>> watchConsumer(String userId) =>
      bookingRepository.watchUserBookings(userId);
  Stream<List<BookingModel>> watchProvider(String providerId) =>
      bookingRepository.watchProviderBookings(providerId);

  Stream<List<BookingModel>> consumerRequests(String userId) =>
      bookingRepository.watchUserBookingsByStatus(userId, [
        BookingModel.pending,
      ]);

  Stream<List<BookingModel>> consumerUpcoming(String userId) =>
      bookingRepository.watchUserBookingsByStatus(userId, [
        BookingModel.accepted,
      ]);

  Stream<List<BookingModel>> consumerHistory(String userId) =>
      bookingRepository.watchUserBookingsByStatus(userId, [
        BookingModel.rejected,
        BookingModel.completed,
        BookingModel.cancelled,
      ]);

  Stream<List<BookingModel>> providerRequests(String providerId) =>
      bookingRepository.watchProviderBookingsByStatus(providerId, [
        BookingModel.pending,
      ]);

  Stream<List<BookingModel>> providerUpcoming(String providerId) =>
      bookingRepository.watchProviderBookingsByStatus(providerId, [
        BookingModel.accepted,
      ]);

  Stream<List<BookingModel>> providerHistory(String providerId) =>
      bookingRepository.watchProviderBookingsByStatus(providerId, [
        BookingModel.rejected,
        BookingModel.completed,
        BookingModel.cancelled,
      ]);

  // Combined streams for providers showing both incoming and outgoing bookings
  Stream<List<BookingWithDirection>> combinedRequests(String userId) {
    return rxdart.Rx.combineLatest2(
      bookingRepository.watchProviderBookingsByStatus(userId, [
        BookingModel.pending,
      ]),
      bookingRepository.watchUserBookingsByStatus(userId, [
        BookingModel.pending,
      ]),
      (List<BookingModel> incoming, List<BookingModel> outgoing) {
        final combined = <BookingWithDirection>[
          ...incoming.map(
            (b) => BookingWithDirection(b, BookingDirection.incoming),
          ),
          ...outgoing.map(
            (b) => BookingWithDirection(b, BookingDirection.outgoing),
          ),
        ];
        combined.sort(
          (a, b) => b.booking.createdAt.compareTo(a.booking.createdAt),
        );
        return combined;
      },
    );
  }

  Stream<List<BookingWithDirection>> combinedUpcoming(String userId) {
    return rxdart.Rx.combineLatest2(
      bookingRepository.watchProviderBookingsByStatus(userId, [
        BookingModel.accepted,
      ]),
      bookingRepository.watchUserBookingsByStatus(userId, [
        BookingModel.accepted,
      ]),
      (List<BookingModel> incoming, List<BookingModel> outgoing) {
        final combined = <BookingWithDirection>[
          ...incoming.map(
            (b) => BookingWithDirection(b, BookingDirection.incoming),
          ),
          ...outgoing.map(
            (b) => BookingWithDirection(b, BookingDirection.outgoing),
          ),
        ];
        combined.sort(
          (a, b) => a.booking.startTime.compareTo(b.booking.startTime),
        );
        return combined;
      },
    );
  }

  Stream<List<BookingWithDirection>> combinedHistory(String userId) {
    return rxdart.Rx.combineLatest2(
      bookingRepository.watchProviderBookingsByStatus(userId, [
        BookingModel.rejected,
        BookingModel.completed,
        BookingModel.cancelled,
      ]),
      bookingRepository.watchUserBookingsByStatus(userId, [
        BookingModel.rejected,
        BookingModel.completed,
        BookingModel.cancelled,
      ]),
      (List<BookingModel> incoming, List<BookingModel> outgoing) {
        final combined = <BookingWithDirection>[
          ...incoming.map(
            (b) => BookingWithDirection(b, BookingDirection.incoming),
          ),
          ...outgoing.map(
            (b) => BookingWithDirection(b, BookingDirection.outgoing),
          ),
        ];
        combined.sort(
          (a, b) =>
              b.booking.updatedAt?.compareTo(
                a.booking.updatedAt ?? b.booking.createdAt,
              ) ??
              0,
        );
        return combined;
      },
    );
  }

  Future<BookingModel?> createBooking({
    required String serviceId,
    required String consumerId,
    required String providerId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
    String? serviceTitle,
    required List<ServiceCategory> categories,
  }) async {
    try {
      isLoading.value = true;
      if (!startTime.isBefore(endTime)) {
        SnackbarUtils.error('Booking failed', 'End time must be after start');
        return null;
      }

      if (categories.isEmpty) {
        SnackbarUtils.error('Booking failed', 'Select at least one category');
        return null;
      }

      final ids = categories.map((c) => c.id).toList();
      final names = categories.map((c) => c.name).toList();
      final totalPrice = categories.fold<double>(0, (sum, c) => sum + c.price);

      final hasClash = await bookingRepository.hasOverlap(
        providerId: providerId,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
      if (hasClash) {
        SnackbarUtils.error('Booking failed', 'Provider is already booked.');
        return null;
      }

      final booking = await bookingRepository.createBooking(
        serviceId: serviceId,
        consumerId: consumerId,
        providerId: providerId,
        categoryIds: ids,
        categoryNames: names,
        totalPrice: totalPrice,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
      await chatRepository.ensureRoom(booking.id, [consumerId, providerId]);
      final consumerName = userStore.value?.displayName;
      await notificationService.notifyNewBooking(
        providerId: providerId,
        bookingId: booking.id,
        serviceTitle: serviceTitle ?? 'service',
        consumerName: consumerName,
      );
      SnackbarUtils.success('Booking created', 'Provider will respond soon');
      return booking;
    } catch (e) {
      SnackbarUtils.error('Booking failed', e.toString());
      debugPrint('Error creating booking: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      final currentUser = userStore.value;
      if (currentUser == null) {
        SnackbarUtils.error('Booking', 'Please sign in again');
        return;
      }
      final booking = await bookingRepository.getBooking(id);
      if (booking == null) {
        SnackbarUtils.error('Booking', 'Booking not found');
        return;
      }

      final isProviderOrAdmin =
          currentUser.role == 'provider' || currentUser.role == 'admin';
      final isConsumer = booking.consumerId == currentUser.id;

      // Provider actions
      if (isProviderOrAdmin) {
        if (booking.isPending &&
            (status == BookingModel.accepted ||
                status == BookingModel.rejected)) {
          await bookingRepository.updateStatus(id, status);
        } else if (booking.isAccepted && status == BookingModel.completed) {
          await bookingRepository.updateStatus(id, status);
        } else if (status == BookingModel.cancelled) {
          await bookingRepository.updateStatus(id, status);
        } else {
          SnackbarUtils.error('Booking', 'Invalid status transition');
          return;
        }
      }
      // Consumer can only cancel pending bookings
      else if (isConsumer &&
          booking.isPending &&
          status == BookingModel.cancelled) {
        await bookingRepository.updateStatus(id, status);
      } else {
        SnackbarUtils.error('Booking', 'You can only cancel pending bookings');
        return;
      }

      final refreshed = await bookingRepository.getBooking(id);
      if (refreshed != null) {
        final userName = userStore.value?.displayName;
        await notificationService.notifyBookingStatusChange(
          booking: refreshed,
          status: status,
          providerName: userName,
        );
      }
      SnackbarUtils.success('Booking', 'Status updated to $status');
    } catch (e) {
      SnackbarUtils.error('Booking', e.toString());
    }
  }
}
