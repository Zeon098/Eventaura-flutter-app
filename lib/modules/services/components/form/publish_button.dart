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
  final TextEditingController descriptionController;
  final TextEditingController locationController;
  final List<String> selectedCategories;
  final Map<String, TextEditingController> categoryPriceControllers;
  final Map<String, String?> categoryPricingTypes;
  final Map<String, String> categoryLabels;
  final List<String> venueSubtypes;

  const PublishButton({
    super.key,
    required this.formKey,
    required this.isEditMode,
    this.editingService,
    required this.titleController,
    required this.descriptionController,
    required this.locationController,
    required this.selectedCategories,
    required this.categoryPriceControllers,
    required this.categoryPricingTypes,
    required this.categoryLabels,
    this.venueSubtypes = const [],
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
                      if (selectedCategories.isEmpty) {
                        SnackbarUtils.error(
                          'Category required',
                          'Select at least one category',
                        );
                        return;
                      }

                      final categories = <ServiceCategory>[];
                      for (final id in selectedCategories) {
                        final controller = categoryPriceControllers[id];
                        final raw = controller?.text.trim() ?? '';
                        final price = double.tryParse(raw);
                        if (price == null) {
                          SnackbarUtils.error(
                            'Price missing',
                            'Enter price for $id',
                          );
                          return;
                        }
                        final pricingType = categoryPricingTypes[id];
                        categories.add(
                          ServiceCategory(
                            id: id,
                            name: categoryLabels[id] ?? id,
                            price: price,
                            pricingType: pricingType,
                          ),
                        );
                      }

                      if (isEditMode && editingService != null) {
                        // Update existing service
                        final updatedService = editingService!.copyWith(
                          title: titleController.text.trim(),
                          categories: categories,
                          description: descriptionController.text.trim(),
                          location: locationController.text.trim(),
                          latitude: controller.latitude.value,
                          longitude: controller.longitude.value,
                          venueSubtypes: venueSubtypes,
                        );
                        controller.updateService(updatedService);
                      } else {
                        // Create new service
                        controller.createService(
                          providerId: shell.user.value?.id ?? '',
                          title: titleController.text.trim(),
                          categories: categories,
                          description: descriptionController.text.trim(),
                          location: locationController.text.trim(),
                          latitude: controller.latitude.value,
                          longitude: controller.longitude.value,
                          venueSubtypes: venueSubtypes,
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
