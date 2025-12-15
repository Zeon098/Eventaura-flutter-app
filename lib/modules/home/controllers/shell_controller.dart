import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/provider_request_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/stores/user_store.dart';
import '../../../core/services/firebase/push_notification_service.dart';
import '../../../data/models/provider_request_model.dart';

class ShellController extends GetxController {
  ShellController({
    required this.authRepository,
    required this.userRepository,
    required this.userStore,
    required this.pushNotificationService,
    required this.providerRequestRepository,
  });

  final AuthRepository authRepository;
  final UserRepository userRepository;
  final UserStore userStore;
  final PushNotificationService pushNotificationService;
  final ProviderRequestRepository providerRequestRepository;

  final tabIndex = 0.obs;
  final user = Rxn<AppUser>();
  final isLoading = true.obs;
  StreamSubscription<AppUser>? _userSub;
  StreamSubscription<ProviderRequest?>? _providerRequestSub;

  @override
  void onInit() {
    super.onInit();
    authRepository.userChanges.listen((appUser) async {
      if (appUser == null) {
        isLoading.value = false;
        userStore.clear();
        Get.offAllNamed('/login');
        await _userSub?.cancel();
        return;
      }
      // Patch auth details without overwriting provider fields.
      final updates = <String, dynamic>{};
      updates['email'] = appUser.email;
      if (appUser.displayName != null)
        updates['displayName'] = appUser.displayName;
      if (appUser.photoUrl != null) updates['photoUrl'] = appUser.photoUrl;
      final token = await pushNotificationService.getToken();
      if (token != null) updates['fcmToken'] = token;
      await userRepository.patchUser(appUser.id, updates);

      await _userSub?.cancel();
      _userSub = userRepository.watchUser(appUser.id).listen((profile) {
        debugPrint('Fetched user profile: $profile');
        if (profile.providerStatus == 'approved' &&
            profile.role != 'provider') {
          userRepository.patchUser(profile.id, {
            'role': 'provider',
            'isProvider': true,
          });
        }
        user.value = profile;
        userStore.setUser(profile);
        isLoading.value = false;
      });

      await _providerRequestSub?.cancel();
      _providerRequestSub = providerRequestRepository
          .watchForUser(appUser.id)
          .listen((req) {
            if (req == null) return;
            _syncUserWithRequest(req);
          });

      // FCM handles notifications via listenForeground() in main.dart
    });
  }

  @override
  void onClose() {
    _userSub?.cancel();
    _providerRequestSub?.cancel();
    super.onClose();
  }

  void changeTab(int index) => tabIndex.value = index;

  Future<void> _syncUserWithRequest(ProviderRequest req) async {
    final profile = user.value;
    if (profile == null) return;
    String? role;
    bool? isProviderFlag;
    switch (req.status) {
      case 'approved':
        role = 'provider';
        isProviderFlag = true;
        break;
      case 'rejected':
      case 'pending':
        role = 'user';
        isProviderFlag = false;
        break;
      default:
        return;
    }
    if (profile.role == role &&
        profile.providerStatus == req.status &&
        profile.isProvider == isProviderFlag) {
      return;
    }
    await userRepository.patchUser(profile.id, {
      'providerStatus': req.status,
      'role': role,
      'isProvider': isProviderFlag,
    });
  }
}
