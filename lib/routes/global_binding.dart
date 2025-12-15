import 'package:get/get.dart';
import '../core/services/algolia_service.dart';
import '../core/services/cloudinary_service.dart';
import '../core/services/firebase/push_notification_service.dart';
import '../core/services/notification_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/booking_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/provider_request_repository.dart';
import '../data/repositories/service_repository.dart';
import '../data/repositories/user_repository.dart';
import '../core/stores/user_store.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<ProviderRequestRepository>(
      ProviderRequestRepository(),
      permanent: true,
    );
    Get.put<UserStore>(UserStore(), permanent: true);
    Get.lazyPut<CloudinaryService>(() => CloudinaryService(), fenix: true);
    Get.lazyPut<AlgoliaService>(() => AlgoliaService(), fenix: true);
    Get.lazyPut<ServiceRepository>(
      () => ServiceRepository(
        cloudinaryService: Get.find<CloudinaryService>(),
        algoliaService: Get.find<AlgoliaService>(),
      ),
      fenix: true,
    );
    Get.put<BookingRepository>(BookingRepository(), permanent: true);
    Get.put<ChatRepository>(ChatRepository(), permanent: true);
    Get.put<PushNotificationService>(
      PushNotificationService(),
      permanent: true,
    );
    Get.put<NotificationService>(
      NotificationService(
        pushNotificationService: Get.find<PushNotificationService>(),
        userRepository: Get.find<UserRepository>(),
      ),
      permanent: true,
    );
  }
}
