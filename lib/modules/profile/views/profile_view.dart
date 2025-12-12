import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProfileContent(controller: controller);
  }
}

class _ProfileContent extends StatefulWidget {
  const _ProfileContent({required this.controller});

  final ProfileController controller;

  @override
  State<_ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<_ProfileContent> {
  final _profileForm = GlobalKey<FormState>();
  final _providerForm = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _city = TextEditingController();
  final _business = TextEditingController();
  final _description = TextEditingController();

  ProfileController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final user = controller.user.value;
        _name.text = user?.displayName ?? '';
        _city.text = user?.city ?? '';
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _glassCard(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: controller.pickAvatar,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        backgroundImage: controller.avatarFile != null
                            ? FileImage(controller.avatarFile!)
                            : (user?.photoUrl != null
                                  ? NetworkImage(user!.photoUrl!)
                                        as ImageProvider
                                  : null),
                        child:
                            controller.avatarFile == null &&
                                user?.photoUrl == null
                            ? const Icon(
                                Icons.camera_alt,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Guest',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.find<ProfileController>()
                          .authRepository
                          .signOut(),
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _glassCard(
                child: Form(
                  key: _profileForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile details',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                        ),
                        validator: (v) => Validators.minLength(v, 2),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _city,
                        decoration: const InputDecoration(labelText: 'City'),
                        validator: Validators.notEmpty,
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : () {
                                  if (_profileForm.currentState?.validate() ??
                                      false) {
                                    controller.saveProfile(
                                      name: _name.text.trim(),
                                      city: _city.text.trim(),
                                    );
                                  }
                                },
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _glassCard(
                child: Form(
                  key: _providerForm,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Become provider',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _business,
                        decoration: const InputDecoration(
                          labelText: 'Business name',
                        ),
                        validator: Validators.notEmpty,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _description,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                        validator: (v) =>
                            Validators.minLength(v, 10, label: 'Description'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _uploadButton(
                            'CNIC Front',
                            onTap: () async {
                              final picked = await controller.picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (picked != null)
                                controller.cnicFront = File(picked.path);
                              setState(() {});
                            },
                          ),
                          const SizedBox(width: 12),
                          _uploadButton(
                            'CNIC Back',
                            onTap: () async {
                              final picked = await controller.picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (picked != null)
                                controller.cnicBack = File(picked.path);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(
                        () => ElevatedButton(
                          onPressed: controller.isSaving.value
                              ? null
                              : () {
                                  if (_providerForm.currentState?.validate() ??
                                      false) {
                                    controller.submitProvider(
                                      businessName: _business.text.trim(),
                                      description: _description.text.trim(),
                                    );
                                  }
                                },
                          child: controller.isSaving.value
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Submit for approval'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _uploadButton(String label, {required VoidCallback onTap}) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.upload),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
