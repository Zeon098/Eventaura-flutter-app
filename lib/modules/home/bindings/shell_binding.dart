import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../services/controllers/service_controller.dart';
import '../../chat/controllers/chat_controller.dart';
import '../../booking/controllers/booking_controller.dart';
import '../controllers/shell_controller.dart';
import '../../../core/stores/user_store.dart';
import '../../../core/services/firebase/push_notification_service.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(
      () => ShellController(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
        userStore: Get.find<UserStore>(),
        pushNotificationService: Get.find<PushNotificationService>(),
      ),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
        cloudinaryService: Get.find<CloudinaryService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ServiceController>(
      () => ServiceController(serviceRepository: Get.find<ServiceRepository>()),
      fenix: true,
    );
    Get.lazyPut<ChatController>(
      () => ChatController(
        chatRepository: Get.find<ChatRepository>(),
        cloudinaryService: Get.find<CloudinaryService>(),
        userRepository: Get.find<UserRepository>(),
        userStore: Get.find<UserStore>(),
        pushNotificationService: Get.find<PushNotificationService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<BookingController>(
      () => BookingController(
        bookingRepository: Get.find<BookingRepository>(),
        chatRepository: Get.find<ChatRepository>(),
        userRepository: Get.find<UserRepository>(),
        pushNotificationService: Get.find<PushNotificationService>(),
      ),
      fenix: true,
    );
  }
}
