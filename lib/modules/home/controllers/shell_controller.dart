import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/stores/user_store.dart';

class ShellController extends GetxController {
  ShellController({
    required this.authRepository,
    required this.userRepository,
    required this.userStore,
  });

  final AuthRepository authRepository;
  final UserRepository userRepository;
  final UserStore userStore;

  final tabIndex = 0.obs;
  final user = Rxn<AppUser>();
  final isLoading = true.obs;
  StreamSubscription<AppUser>? _userSub;

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
      await userRepository.patchUser(appUser.id, updates);

      await _userSub?.cancel();
      _userSub = userRepository.watchUser(appUser.id).listen((profile) {
        debugPrint('Fetched user profile: $profile');
        user.value = profile;
        userStore.setUser(profile);
        isLoading.value = false;
      });
    });
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }

  void changeTab(int index) => tabIndex.value = index;
}
