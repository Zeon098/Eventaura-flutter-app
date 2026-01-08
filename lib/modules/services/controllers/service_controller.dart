import 'dart:io';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../core/services/location_service.dart';
import '../../../core/stores/user_store.dart';

class ServiceController extends GetxController {
  ServiceController({
    required this.serviceRepository,
    required this.locationService,
    required this.userStore,
  });

  final ServiceRepository serviceRepository;
  final LocationService locationService;
  final UserStore userStore;
  final services = <ServiceModel>[].obs;
  final isLoading = false.obs;
  final picker = ImagePicker();
  File? cover;
  final gallery = <File>[];
  final Rxn<double> latitude = Rxn<double>();
  final Rxn<double> longitude = Rxn<double>();
  final locationLabel = ''.obs;
  StreamSubscription<List<ServiceModel>>? _allSub;
  StreamSubscription<List<ServiceModel>>? _providerSub;

  @override
  void onClose() {
    _allSub?.cancel();
    _providerSub?.cancel();
    super.onClose();
  }

  void bindAllServices() {
    _providerSub?.cancel();
    _allSub?.cancel();
    _allSub = serviceRepository.streamAllServices().listen(
      services.assignAll,
      onError: (e) {
        SnackbarUtils.error('Services', e.toString());
        debugPrint('Error streaming services: $e');
      },
    );
  }

  void bindProviderServices(String providerId) {
    _allSub?.cancel();
    _providerSub?.cancel();
    _providerSub = serviceRepository
        .streamProviderServices(providerId)
        .listen(
          services.assignAll,
          onError: (e) {
            SnackbarUtils.error('Services', e.toString());
          },
        );
  }

  Future<void> pickCover() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) cover = File(picked.path);
    update();
  }

  Future<void> pickGallery() async {
    final picked = await picker.pickMultiImage(imageQuality: 80);
    gallery.addAll(picked.take(5 - gallery.length).map((x) => File(x.path)));
    update();
  }

  Future<void> createService({
    required String providerId,
    required String title,
    required List<ServiceCategory> categories,
    required String description,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    if (cover == null) {
      SnackbarUtils.error('Missing cover', 'Upload a cover image');
      return;
    }
    if (categories.isEmpty) {
      SnackbarUtils.error('Category required', 'Select at least one category');
      return;
    }
    try {
      isLoading.value = true;
      await serviceRepository.createService(
        providerId: providerId,
        title: title,
        categories: categories,
        description: description,
        location: location,
        cover: cover!,
        gallery: gallery,
        latitude: latitude ?? this.latitude.value ?? userStore.value?.latitude,
        longitude:
            longitude ?? this.longitude.value ?? userStore.value?.longitude,
      );
      SnackbarUtils.success('Created', 'Service published');
    } catch (e) {
      debugPrint('Error creating service: $e');
      SnackbarUtils.error('Service', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateService(ServiceModel service) async {
    try {
      isLoading.value = true;
      await serviceRepository.updateService(
        service,
        newCover: cover,
        newGallery: gallery,
      );
      SnackbarUtils.success('Updated', 'Service saved');
    } catch (e) {
      SnackbarUtils.error('Update', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteService(String id) async {
    try {
      isLoading.value = true;
      await serviceRepository.deleteService(id);
      SnackbarUtils.success('Deleted', 'Service removed');
    } catch (e) {
      SnackbarUtils.error('Delete', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void clearMedia() {
    cover = null;
    gallery.clear();
    update();
  }

  Future<void> fetchCurrentLocation() async {
    try {
      isLoading.value = true;
      final position = await locationService.getCurrentPosition();
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      final city = await locationService.reverseGeocodeCity(
        position.latitude,
        position.longitude,
      );
      if (city != null) locationLabel.value = city;
      update();
    } on PermissionDeniedException catch (e) {
      SnackbarUtils.error('Location', e.message);
    } catch (e) {
      SnackbarUtils.error('Location', e.toString());
      debugPrint('Location permission denied: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
}
