import 'package:get/get.dart';
import '../theme/app_colors.dart';

class SnackbarUtils {
  SnackbarUtils._();

  static void success(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.success.withOpacity(0.1),
    );
  }

  static void error(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.error.withOpacity(0.1),
    );
  }
}
