import 'package:get/get.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/services/firebase/push_notification_service.dart';
import '../../../core/stores/user_store.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(
      () => ChatController(
        chatRepository: Get.find<ChatRepository>(),
        cloudinaryService: Get.find<CloudinaryService>(),
        userRepository: Get.find<UserRepository>(),
        userStore: Get.find<UserStore>(),
        pushNotificationService: Get.find<PushNotificationService>(),
      ),
    );
  }
}
