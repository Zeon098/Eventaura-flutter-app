import 'package:get/get.dart';
import '../core/services/algolia_service.dart';
import '../core/services/cloudinary_service.dart';
import '../core/services/firebase/push_notification_service.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/booking_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/service_repository.dart';
import '../data/repositories/user_repository.dart';

class GlobalBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthRepository>(AuthRepository(), permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
    Get.put<CloudinaryService>(CloudinaryService(), permanent: true);
    Get.put<AlgoliaService>(AlgoliaService(), permanent: true);
    Get.put<ServiceRepository>(
      ServiceRepository(
        cloudinaryService: Get.find(),
        algoliaService: Get.find(),
      ),
      permanent: true,
    );
    Get.put<BookingRepository>(BookingRepository(), permanent: true);
    Get.put<ChatRepository>(ChatRepository(), permanent: true);
    Get.put<PushNotificationService>(
      PushNotificationService(),
      permanent: true,
    );
  }
}
