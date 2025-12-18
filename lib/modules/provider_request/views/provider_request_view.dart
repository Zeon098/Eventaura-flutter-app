import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/shell_controller.dart';
import '../controllers/provider_request_controller.dart';

class ProviderRequestView extends StatefulWidget {
  const ProviderRequestView({super.key});

  @override
  State<ProviderRequestView> createState() => _ProviderRequestViewState();
}

class _ProviderRequestViewState extends State<ProviderRequestView> {
  final _formKey = GlobalKey<FormState>();
  final _business = TextEditingController();
  final _description = TextEditingController();

  ProviderRequestController get controller => Get.find();

  @override
  void initState() {
    super.initState();
    final req = controller.request.value;
    if (req != null) {
      _business.text = req.businessName;
      _description.text = req.description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a provider')),
      body: GetBuilder<ProviderRequestController>(
        builder: (_) {
          final req = controller.request.value;
          final status = req?.status ?? 'none';
          if (req != null) {
            if (_business.text.isEmpty) _business.text = req.businessName;
            if (_description.text.isEmpty) {
              _description.text = req.description;
            }
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _statusCard(
                  status: status,
                  rejectionReason: req?.rejectionReason,
                ),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _business,
                        decoration: const InputDecoration(
                          labelText: 'Business name',
                        ),
                        validator: Validators.notEmpty,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                        validator: (v) =>
                            Validators.minLength(v, 10, label: 'Description'),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _uploadTile(
                              label: 'CNIC Front',
                              file: controller.cnicFront,
                              networkUrl: req?.cnicFrontUrl,
                              onTap: controller.pickFront,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _uploadTile(
                              label: 'CNIC Back',
                              file: controller.cnicBack,
                              networkUrl: req?.cnicBackUrl,
                              onTap: controller.pickBack,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: controller.isSubmitting.value
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(
                              status == 'approved'
                                  ? 'You are approved'
                                  : status == 'pending'
                                  ? 'Awaiting approval'
                                  : 'Submit for approval',
                            ),
                            onPressed:
                                controller.isSubmitting.value ||
                                    !controller.canSubmit
                                ? null
                                : () async {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
                                      await controller.submit(
                                        businessName: _business.text.trim(),
                                        description: _description.text.trim(),
                                      );
                                    }
                                  },
                          ),
                        ),
                      ),
                      if (status == 'approved') ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            final shellReady =
                                Get.isRegistered<ShellController>();
                            if (shellReady) {
                              Get.find<ShellController>().changeTab(3);
                            }
                            Get.offAllNamed(Routes.shell);
                          },
                          icon: const Icon(Icons.store_mall_directory),
                          label: const Text('Go to Services'),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statusCard({required String status, String? rejectionReason}) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = Colors.green;
        label = 'Approved';
        break;
      case 'pending':
        color = Colors.orange;
        label = 'Pending review';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Rejected';
        break;
      default:
        color = AppTheme.textSecondaryColor;
        label = 'Not submitted';
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            status == 'approved'
                ? 'Your account is approved. You can publish services.'
                : status == 'pending'
                ? 'We are reviewing your documents. This usually takes 24-48 hours.'
                : status == 'rejected'
                ? (rejectionReason?.isNotEmpty == true
                      ? 'Request rejected: $rejectionReason'
                      : 'Request rejected. Please resubmit with correct details.')
                : 'Submit a request to start selling your services.',
          ),
        ],
      ),
    );
  }

  Widget _uploadTile({
    required String label,
    required VoidCallback onTap,
    File? file,
    String? networkUrl,
  }) {
    final hasImage = file != null || (networkUrl?.isNotEmpty ?? false);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasImage ? AppTheme.primaryColor : Colors.grey.shade300,
          ),
          image: hasImage
              ? DecorationImage(
                  fit: BoxFit.cover,
                  image: file != null
                      ? FileImage(file)
                      : NetworkImage(networkUrl!) as ImageProvider,
                )
              : null,
        ),
        alignment: Alignment.center,
        child: hasImage
            ? const SizedBox.shrink()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload_file, color: AppTheme.primaryColor),
                  const SizedBox(height: 6),
                  Text(label),
                ],
              ),
      ),
    );
  }
}
