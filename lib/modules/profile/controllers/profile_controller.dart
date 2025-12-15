import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/stores/user_store.dart';
import '../../../core/services/location_service.dart';

class ProfileController extends GetxController {
  ProfileController({
    required this.authRepository,
    required this.userRepository,
    required this.cloudinaryService,
    required this.userStore,
    required this.locationService,
  });

  final AuthRepository authRepository;
  final UserRepository userRepository;
  final CloudinaryService cloudinaryService;
  final UserStore userStore;
  final LocationService locationService;

  final user = Rxn<AppUser>();
  final isSaving = false.obs;
  final picker = ImagePicker();
  File? avatarFile;
  final Rxn<double> latitude = Rxn<double>();
  final Rxn<double> longitude = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    ever<AppUser?>(userStore.user, (profile) {
      if (profile != null) user.value = profile;
      latitude.value = profile?.latitude;
      longitude.value = profile?.longitude;
    });
    final current = userStore.value;
    if (current != null) user.value = current;
    authRepository.userChanges.listen((appUser) async {
      if (appUser != null && user.value == null) {
        user.value = await userRepository.fetchUser(appUser.id);
        latitude.value = user.value?.latitude;
        longitude.value = user.value?.longitude;
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

  Future<void> updateLocationFromDevice() async {
    try {
      isSaving.value = true;
      final position = await locationService.getCurrentPosition();
      final city = await locationService.reverseGeocodeCity(
        position.latitude,
        position.longitude,
      );
      final updates = {
        'latitude': position.latitude,
        'longitude': position.longitude,
        if (city != null) 'city': city,
      };
      if (user.value != null) {
        await userRepository.patchUser(user.value!.id, updates);
        user.value = user.value!.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          city: city ?? user.value!.city,
        );
        userStore.setUser(user.value);
      }
      SnackbarUtils.success('Location updated', 'Coordinates saved to profile');
    } on PermissionDeniedException catch (e) {
      SnackbarUtils.error('Location', e.message);
    } catch (e) {
      SnackbarUtils.error('Location', e.toString());
    } finally {
      isSaving.value = false;
    }
  }
}
