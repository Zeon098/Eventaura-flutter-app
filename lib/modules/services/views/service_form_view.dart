import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/validators.dart';
import '../../home/controllers/shell_controller.dart';
import '../controllers/service_controller.dart';

class ServiceFormView extends StatefulWidget {
  const ServiceFormView({super.key});

  @override
  State<ServiceFormView> createState() => _ServiceFormViewState();
}

class _ServiceFormViewState extends State<ServiceFormView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _category = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _location = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceController>();
    final shell = Get.find<ShellController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add service')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: Validators.notEmpty,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: Validators.notEmpty,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: Validators.notEmpty,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: Validators.notEmpty,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (v) =>
                    Validators.minLength(v, 10, label: 'Description'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: controller.pickCover,
                    icon: const Icon(Icons.image),
                    label: const Text('Cover'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: controller.pickGallery,
                    icon: const Icon(Icons.collections),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final price =
                                double.tryParse(_price.text.trim()) ?? 0;
                            controller.createService(
                              providerId: shell.user.value?.id ?? '',
                              title: _title.text.trim(),
                              category: _category.text.trim(),
                              price: price,
                              description: _description.text.trim(),
                              location: _location.text.trim(),
                            );
                          }
                        },
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Publish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
