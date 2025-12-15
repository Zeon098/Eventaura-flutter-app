import 'package:get/get.dart';
import '../../../data/repositories/service_repository.dart';
import '../controllers/service_controller.dart';
import '../../../core/services/location_service.dart';
import '../../../core/stores/user_store.dart';

class ServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceController>(
      () => ServiceController(
        serviceRepository: Get.find<ServiceRepository>(),
        locationService: Get.find<LocationService>(),
        userStore: Get.find<UserStore>(),
      ),
    );
  }
}
