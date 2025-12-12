import 'package:get/get.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../controllers/shell_controller.dart';

class ShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShellController>(
      () => ShellController(
        authRepository: Get.find<AuthRepository>(),
        userRepository: Get.find<UserRepository>(),
      ),
    );
  }
}
