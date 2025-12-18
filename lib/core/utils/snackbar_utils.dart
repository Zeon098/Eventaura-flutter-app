import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';

class SnackbarUtils {
  SnackbarUtils._();

  static void success(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.successColor.withOpacity(0.1),
    );
  }

  static void error(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: AppTheme.errorColor.withOpacity(0.1),
    );
  }
}
