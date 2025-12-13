import 'package:get/get.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/services/firebase/push_notification_service.dart';
import '../controllers/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(
      () => BookingController(
        bookingRepository: Get.find<BookingRepository>(),
        chatRepository: Get.find(),
        userRepository: Get.find<UserRepository>(),
        pushNotificationService: Get.find<PushNotificationService>(),
      ),
    );
  }
}
