import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../home/controllers/shell_controller.dart';
import '../../../widgets/address_picker_field.dart';
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
  final _name = TextEditingController();
  final _city = TextEditingController();
  double? _lat;
  double? _lng;

  ProfileController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Obx(() {
        final user = controller.user.value;
        _name.text = user?.displayName ?? '';
        _city.text = user?.city ?? '';
        _lat = user?.latitude;
        _lng = user?.longitude;
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
                        backgroundColor: AppTheme.primaryColor.withOpacity(
                          0.15,
                        ),
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
                                color: AppTheme.primaryColor,
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
                      AddressPickerField(
                        label: 'Location',
                        hint: 'Pick your address',
                        controller: _city,
                        initialLat: _lat,
                        initialLng: _lng,
                        onChanged: (addr, lat, lng) {
                          _city.text = addr;
                          _lat = lat;
                          _lng = lng;
                        },
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
                                      latitude: _lat,
                                      longitude: _lng,
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
              _providerCard(user),
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

  Widget _providerCard(AppUser? user) {
    final status = user?.providerStatus ?? 'none';
    final isProvider = user?.role == 'provider' || status == 'approved';
    final isSubmitted = status == 'pending' || isProvider;
    Color chipColor;
    String chipText;
    switch (status) {
      case 'pending':
        chipColor = Colors.orange;
        chipText = 'Pending review';
        break;
      case 'approved':
        chipColor = Colors.green;
        chipText = 'Approved provider';
        break;
      case 'rejected':
        chipColor = Colors.red;
        chipText = 'Rejected';
        break;
      default:
        chipColor = AppTheme.textSecondaryColor;
        chipText = 'Not submitted';
    }

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Provider account',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: chipColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  chipText,
                  style: TextStyle(
                    color: chipColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isProvider
                ? 'Your provider account is active. Publish and manage services.'
                : status == 'pending'
                ? 'We are reviewing your documents. You will be notified once approved.'
                : 'Submit your CNIC to become a verified provider.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: isSubmitted
                      ? null
                      : () => Get.toNamed(Routes.providerRequest),
                  child: Text(
                    isProvider
                        ? 'Approved'
                        : isSubmitted
                        ? 'Submitted'
                        : 'Become a provider',
                  ),
                ),
              ),
              if (isSubmitted)
                TextButton(
                  onPressed: () => Get.toNamed(Routes.providerRequest),
                  child: const Text('View request'),
                ),
            ],
          ),
          if (isProvider)
            TextButton.icon(
              onPressed: () {
                final shell = Get.find<ShellController>();
                shell.changeTab(3);
              },
              icon: const Icon(Icons.store_mall_directory),
              label: const Text('Go to Services'),
            ),
        ],
      ),
    );
  }
}
