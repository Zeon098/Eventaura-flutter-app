import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/provider_request_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/services/cloudinary_service.dart';

class ProfileController extends GetxController {
  ProfileController({
    required this.authRepository,
    required this.userRepository,
    required this.cloudinaryService,
  });

  final AuthRepository authRepository;
  final UserRepository userRepository;
  final CloudinaryService cloudinaryService;

  final user = Rxn<AppUser>();
  final isSaving = false.obs;
  final picker = ImagePicker();
  File? avatarFile;
  File? cnicFront;
  File? cnicBack;

  @override
  void onInit() {
    super.onInit();
    authRepository.userChanges.listen((appUser) async {
      if (appUser != null) {
        user.value = await userRepository.fetchUser(appUser.id);
      }
    });
  }

  Future<void> pickAvatar() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) avatarFile = File(picked.path);
    update();
  }

  Future<void> saveProfile({required String name, required String city}) async {
    if (user.value == null) return;
    try {
      isSaving.value = true;
      String? photoUrl = user.value!.photoUrl;
      if (avatarFile != null) {
        photoUrl = await cloudinaryService.uploadImage(
          avatarFile!,
          folder: 'profiles',
        );
      }
      final updated = user.value!.copyWith(
        displayName: name,
        city: city,
        photoUrl: photoUrl,
      );
      await userRepository.upsertUser(updated);
      user.value = updated;
      SnackbarUtils.success('Saved', 'Profile updated');
    } catch (e) {
      SnackbarUtils.error('Profile', e.toString());
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> submitProvider({
    required String businessName,
    required String description,
  }) async {
    if (user.value == null) return;
    try {
      if (cnicFront == null || cnicBack == null) {
        SnackbarUtils.error('Missing files', 'Upload CNIC images');
        return;
      }
      isSaving.value = true;
      final frontUrl = await cloudinaryService.uploadImage(
        cnicFront!,
        folder: 'cnic',
      );
      final backUrl = await cloudinaryService.uploadImage(
        cnicBack!,
        folder: 'cnic',
      );
      final request = ProviderRequest(
        userId: user.value!.id,
        businessName: businessName,
        description: description,
        cnicFrontUrl: frontUrl,
        cnicBackUrl: backUrl,
      );
      await userRepository.submitProviderRequest(request);
      SnackbarUtils.success('Submitted', 'Your request is pending approval');
    } catch (e) {
      SnackbarUtils.error('Provider request', e.toString());
    } finally {
      isSaving.value = false;
    }
  }
}
