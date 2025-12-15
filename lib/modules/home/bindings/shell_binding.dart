import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/location_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/provider_request_repository.dart';
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
        providerRequestRepository: Get.find<ProviderRequestRepository>(),
      ),
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
        cloudinaryService: Get.find<CloudinaryService>(),
        userStore: Get.find<UserStore>(),
        locationService: Get.find<LocationService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ServiceController>(
      () => ServiceController(
        serviceRepository: Get.find<ServiceRepository>(),
        locationService: Get.find<LocationService>(),
        userStore: Get.find<UserStore>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ChatController>(
      () => ChatController(
        chatRepository: Get.find<ChatRepository>(),
        cloudinaryService: Get.find<CloudinaryService>(),
        userStore: Get.find<UserStore>(),
        notificationService: Get.find<NotificationService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<BookingController>(
      () => BookingController(
        bookingRepository: Get.find<BookingRepository>(),
        chatRepository: Get.find<ChatRepository>(),
        userRepository: Get.find<UserRepository>(),
        notificationService: Get.find<NotificationService>(),
        userStore: Get.find<UserStore>(),
      ),
      fenix: true,
    );
  }
}
