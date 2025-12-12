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
  }) async {
    final ref = _firestore.collection(AppConstants.bookingsCollection).doc();
    final createdAt = DateTime.now();
    await ref.set({
      'serviceId': serviceId,
      'consumerId': consumerId,
      'providerId': providerId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return BookingModel(
      id: ref.id,
      serviceId: serviceId,
      consumerId: consumerId,
      providerId: providerId,
      createdAt: createdAt,
      status: 'pending',
    );
  }

  Future<void> updateStatus(String bookingId, String status) async {
    await _firestore
        .collection(AppConstants.bookingsCollection)
        .doc(bookingId)
        .update({'status': status});
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
    return _firestore
        .collection(AppConstants.bookingsCollection)
        .where('consumerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => BookingModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<BookingModel>> watchProviderBookings(String providerId) {
    return _firestore
        .collection(AppConstants.bookingsCollection)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => BookingModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }
}
