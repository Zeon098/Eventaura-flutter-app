import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_constants.dart';
import '../models/booking_model.dart';

class BookingRepository {
  BookingRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<BookingModel> createBooking({
    required String serviceId,
    required String consumerId,
    required String providerId,
    required List<String> categoryIds,
    required List<String> categoryNames,
    required double totalPrice,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final ref = _firestore.collection(AppConstants.bookingsCollection).doc();
    final createdAt = DateTime.now();
    final dateKey = _dateKey(date);
    await ref.set({
      'serviceId': serviceId,
      'consumerId': consumerId,
      'providerId': providerId,
      'categoryId': categoryIds.isNotEmpty ? categoryIds.first : null,
      'categoryName': categoryNames.isNotEmpty ? categoryNames.first : null,
      'categoryPrice': totalPrice,
      'categoryIds': categoryIds,
      'categoryNames': categoryNames,
      'totalPrice': totalPrice,
      'date': dateKey,
      'startTime': Timestamp.fromDate(startTime.toUtc()),
      'endTime': Timestamp.fromDate(endTime.toUtc()),
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return BookingModel(
      id: ref.id,
      serviceId: serviceId,
      consumerId: consumerId,
      providerId: providerId,
      categoryId: categoryIds.isNotEmpty ? categoryIds.first : null,
      categoryName: categoryNames.isNotEmpty ? categoryNames.first : null,
      categoryPrice: totalPrice,
      categoryIds: categoryIds,
      categoryNames: categoryNames,
      totalPrice: totalPrice,
      dateKey: dateKey,
      startTime: startTime,
      endTime: endTime,
      createdAt: createdAt,
      updatedAt: createdAt,
      status: 'pending',
    );
  }

  Future<bool> hasOverlap({
    required String providerId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    // Fetch all same-day bookings for provider and filter in-memory to avoid composite index
    final dateKey = _dateKey(date);
    final snap = await _firestore
        .collection(AppConstants.bookingsCollection)
        .where('providerId', isEqualTo: providerId)
        .where('date', isEqualTo: dateKey)
        .get();

    for (final doc in snap.docs) {
      final existing = BookingModel.fromMap(doc.id, doc.data());

      // Only check pending/accepted bookings
      if (existing.status != BookingModel.pending &&
          existing.status != BookingModel.accepted) {
        continue;
      }

      // Check for time overlap: existing.start < new.end AND existing.end > new.start
      if (existing.startTime.isBefore(endTime) &&
          existing.endTime.isAfter(startTime)) {
        return true;
      }
    }
    return false;
  }

  Future<void> updateStatus(String bookingId, String status) async {
    await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .update({'status': status, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<BookingModel?> getBooking(String id) async {
    final doc = await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return BookingModel.fromMap(doc.id, doc.data() ?? {});
  }

  Stream<List<BookingModel>> watchUserBookings(String userId) {
    return _watchByRole('consumerId', userId);
  }

  Stream<List<BookingModel>> watchProviderBookings(String providerId) {
    return _watchByRole('providerId', providerId);
  }

  Stream<List<BookingModel>> watchUserBookingsByStatus(
    String userId,
    List<String> statuses,
  ) {
    return _watchByRole('consumerId', userId, statuses: statuses);
  }

  Stream<List<BookingModel>> watchProviderBookingsByStatus(
    String providerId,
    List<String> statuses,
  ) {
    return _watchByRole('providerId', providerId, statuses: statuses);
  }

  Stream<List<BookingModel>> _watchByRole(
    String field,
    String id, {
    List<String>? statuses,
  }) {
    // Fetch all bookings for the user/provider and filter by status in-memory
    // to avoid composite index requirement (whereIn + orderBy)
    return _firestore
        .collection(AppConstants.bookingsCollection)
        .where(field, isEqualTo: id)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) {
          final bookings = snap.docs
              .map((d) => BookingModel.fromMap(d.id, d.data()))
              .toList();

          if (statuses == null || statuses.isEmpty) {
            return bookings;
          }

          return bookings.where((b) => statuses.contains(b.status)).toList();
        });
  }

  String _dateKey(DateTime date) {
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');
    return '${date.year}-$mm-$dd';
  }
}
