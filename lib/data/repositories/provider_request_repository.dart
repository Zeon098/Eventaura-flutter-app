import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_constants.dart';
import '../models/provider_request_model.dart';

class ProviderRequestRepository {
  ProviderRequestRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(AppConstants.providerRequestsCollection);

  Future<void> submit(ProviderRequest request) async {
    final now = FieldValue.serverTimestamp();
    await _collection.doc(request.id).set({
      ...request.toMap(),
      'createdAt': request.createdAt ?? now,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  Future<ProviderRequest?> fetchForUser(String userId) async {
    final snap = await _collection.doc(userId).get();
    if (!snap.exists) return null;
    final data = snap.data();
    if (data == null) return null;
    return ProviderRequest.fromMap(data);
  }

  Stream<ProviderRequest?> watchForUser(String userId) {
    return _collection.doc(userId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return ProviderRequest.fromMap(data);
    });
  }

  Future<void> updateStatus({
    required String userId,
    required String status,
    String? rejectionReason,
  }) async {
    await _collection.doc(userId).set({
      'status': status,
      'rejectionReason': rejectionReason,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
