import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/controllers/shell_controller.dart';
import '../../services/controllers/service_controller.dart';
import '../../services/views/service_form_view.dart';
import '../components/service_card.dart';
import '../components/empty_services_state.dart';
import '../components/services_loading_state.dart';

class ProviderServicesView extends GetView<ServiceController> {
  const ProviderServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    controller.bindProviderServices(shell.user.value?.id ?? '');

    return Scaffold(
      appBar: AppBar(title: const Text('My services')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ServiceFormView()),
        label: const Text(
          'Add Service',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ServicesLoadingState();
        }

        if (controller.services.isEmpty) {
          return const EmptyServicesState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: controller.services.length,
          itemBuilder: (_, index) {
            final service = controller.services[index];
            return ServiceCard(
              service: service,
              onTap: () =>
                  Get.to(() => const ServiceFormView(), arguments: service),
            );
          },
        );
      }),
    );
  }
}
