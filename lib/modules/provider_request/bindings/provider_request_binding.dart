import 'package:get/get.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/stores/user_store.dart';
import '../../../data/repositories/provider_request_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../controllers/provider_request_controller.dart';

class ProviderRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProviderRequestController>(
      () => ProviderRequestController(
        providerRequestRepository: Get.find<ProviderRequestRepository>(),
        cloudinaryService: Get.find<CloudinaryService>(),
        userStore: Get.find<UserStore>(),
        userRepository: Get.find<UserRepository>(),
      ),
    );
  }
}
