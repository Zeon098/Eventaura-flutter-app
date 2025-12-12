import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

class ShellController extends GetxController {
  ShellController({required this.authRepository, required this.userRepository});

  final AuthRepository authRepository;
  final UserRepository userRepository;

  final tabIndex = 0.obs;
  final user = Rxn<AppUser>();
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    authRepository.userChanges.listen((appUser) async {
      if (appUser == null) {
        isLoading.value = false;
        Get.offAllNamed('/login');
        return;
      }
      final profile = await userRepository.fetchUser(appUser.id);
      user.value = profile.copyWith(
        displayName: appUser.displayName,
        photoUrl: appUser.photoUrl,
        providerStatus: profile.providerStatus,
      );
      isLoading.value = false;
    });
  }

  void changeTab(int index) => tabIndex.value = index;
}
