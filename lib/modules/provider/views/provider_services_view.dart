import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/shell_controller.dart';
import '../../services/controllers/service_controller.dart';
import '../../services/views/service_form_view.dart';

class ProviderServicesView extends StatefulWidget {
  const ProviderServicesView({super.key});

  @override
  State<ProviderServicesView> createState() => _ProviderServicesViewState();
}

class _ProviderServicesViewState extends State<ProviderServicesView> {
  @override
  void initState() {
    super.initState();
    final shell = Get.find<ShellController>();
    final serviceController = Get.put<ServiceController>(
      ServiceController(serviceRepository: Get.find()),
    );
    serviceController.bindProviderServices(shell.user.value?.id ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();
    return Scaffold(
      appBar: AppBar(title: const Text('My services')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const ServiceFormView()),
        label: const Text('Add service'),
        icon: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.services.isEmpty) {
          return const Center(child: Text('No services yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.services.length,
          itemBuilder: (_, index) {
            final service = controller.services[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 2,
              child: ListTile(
                title: Text(service.title),
                subtitle: Text(
                  '${service.category} • PKR ${service.price.toStringAsFixed(0)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Get.to(() => const ServiceFormView(), arguments: service),
              ),
            );
          },
        );
      }),
    );
  }
}
