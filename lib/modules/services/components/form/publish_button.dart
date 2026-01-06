import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../home/controllers/shell_controller.dart';
import '../../../../data/models/service_model.dart';
import '../../controllers/service_controller.dart';

class PublishButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isEditMode;
  final ServiceModel? editingService;
  final TextEditingController titleController;
  final TextEditingController priceController;
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final List<String> selectedCategories;

  const PublishButton({
    super.key,
    required this.formKey,
    required this.isEditMode,
    this.editingService,
    required this.titleController,
    required this.priceController,
    required this.descriptionController,
    required this.locationController,
    required this.selectedCategories,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();
    final shell = Get.find<ShellController>();

    return Obx(
      () => Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: controller.isLoading.value
                ? null
                : () {
                    if (formKey.currentState?.validate() ?? false) {
                      final price =
                          double.tryParse(priceController.text.trim()) ?? 0;

                      if (selectedCategories.isEmpty) {
                        SnackbarUtils.error(
                          'Category required',
                          'Select at least one category',
                        );
                        return;
                      }

                      if (isEditMode && editingService != null) {
                        // Update existing service
                        final updatedService = editingService!.copyWith(
                          title: titleController.text.trim(),
                          categories: selectedCategories,
                          price: price,
                          description: descriptionController.text.trim(),
                          location: locationController.text.trim(),
                          latitude: controller.latitude.value,
                          longitude: controller.longitude.value,
                        );
                        controller.updateService(updatedService);
                      } else {
                        // Create new service
                        controller.createService(
                          providerId: shell.user.value?.id ?? '',
                          title: titleController.text.trim(),
                          categories: selectedCategories,
                          price: price,
                          description: descriptionController.text.trim(),
                          location: locationController.text.trim(),
                          latitude: controller.latitude.value,
                          longitude: controller.longitude.value,
                        );
                      }
                    }
                  },
            child: Center(
              child: controller.isLoading.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isEditMode ? Icons.save : Icons.publish,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          isEditMode ? 'Update Service' : 'Publish Service',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
