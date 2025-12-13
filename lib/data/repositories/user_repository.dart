import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/app_constants.dart';
import '../models/provider_request_model.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> upsertUser(AppUser user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser> fetchUser(String id) async {
    final snap = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(id)
        .get();
    return AppUser.fromMap(id, snap.data() ?? {});
  }

  Future<void> submitProviderRequest(ProviderRequest request) async {
    await _firestore
        .collection(AppConstants.providerRequestsCollection)
        .doc(request.userId)
        .set(request.toMap());
  }

  Future<void> patchUser(String id, Map<String, dynamic> data) async {
    if (data.isEmpty) return;
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(id)
        .set(data, SetOptions(merge: true));
  }

  Stream<AppUser> watchUser(String id) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(id)
        .snapshots()
        .map((snap) => AppUser.fromMap(id, snap.data() ?? {}));
  }
}
