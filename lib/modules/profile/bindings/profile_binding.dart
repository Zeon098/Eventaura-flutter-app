import 'package:get/get.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/stores/user_store.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
        cloudinaryService: Get.find<CloudinaryService>(),
        userStore: Get.find<UserStore>(),
      ),
    );
  }
}
