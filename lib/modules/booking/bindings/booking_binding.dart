import 'package:get/get.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/stores/user_store.dart';
import '../../../data/repositories/booking_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../controllers/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(
      () => BookingController(
        bookingRepository: Get.find<BookingRepository>(),
        chatRepository: Get.find(),
        userRepository: Get.find<UserRepository>(),
        notificationService: Get.find<NotificationService>(),
        userStore: Get.find<UserStore>(),
      ),
    );
  }
}
