import 'dart:io';
import 'dart:async';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';

class ServiceController extends GetxController {
  ServiceController({required this.serviceRepository});

  final ServiceRepository serviceRepository;
  final services = <ServiceModel>[].obs;
  final isLoading = false.obs;
  final picker = ImagePicker();
  File? cover;
  final gallery = <File>[];
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
    required String category,
    required double price,
    required String description,
    required String location,
    double? latitude,
    double? longitude,
  }) async {
    if (cover == null) {
      SnackbarUtils.error('Missing cover', 'Upload a cover image');
      return;
    }
    try {
      isLoading.value = true;
      await serviceRepository.createService(
        providerId: providerId,
        title: title,
        category: category,
        price: price,
        description: description,
        location: location,
        cover: cover!,
        gallery: gallery,
        latitude: latitude,
        longitude: longitude,
      );
      SnackbarUtils.success('Created', 'Service published');
    } catch (e) {
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
}
