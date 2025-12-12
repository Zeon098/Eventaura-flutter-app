import 'package:get/get.dart';
import '../../../data/repositories/booking_repository.dart';
import '../controllers/booking_controller.dart';

class BookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(
      () => BookingController(
        bookingRepository: Get.find<BookingRepository>(),
        chatRepository: Get.find(),
      ),
    );
  }
}
