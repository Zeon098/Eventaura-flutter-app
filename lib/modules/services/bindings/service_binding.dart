import 'package:get/get.dart';
import '../../../data/repositories/service_repository.dart';
import '../controllers/service_controller.dart';

class ServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceController>(
      () => ServiceController(serviceRepository: Get.find<ServiceRepository>()),
    );
  }
}
