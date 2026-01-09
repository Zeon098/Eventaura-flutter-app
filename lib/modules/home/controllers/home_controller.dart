import 'dart:async';
import 'package:get/get.dart';
import '../../../core/services/location_service.dart';
import '../../../core/stores/user_store.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';

class HomeController extends GetxController {
  HomeController({
    required this.serviceRepository,
    required this.locationService,
    required this.userStore,
  });

  final ServiceRepository serviceRepository;
  final LocationService locationService;
  final UserStore userStore;

  final trending = <ServiceModel>[].obs;
  final nearby = <ServiceModel>[].obs;
  final myServices = <ServiceModel>[].obs;
  final trendingLoading = false.obs;
  final nearbyLoading = false.obs;
  final myServicesLoading = false.obs;
  final error = RxnString();
  final hasLocation = false.obs;
  double? userLat;
  double? userLng;
  Stream<List<ServiceModel>>? _myServicesStream;
  StreamSubscription<List<ServiceModel>>? _myServicesSub;

  @override
  void onInit() {
    super.onInit();
    loadTrending();
    _loadMyServices();
    _loadNearby();
  }

  @override
  void onClose() {
    _myServicesSub?.cancel();
    super.onClose();
  }

  Future<void> loadTrending() async {
    try {
      trendingLoading.value = true;
      error.value = null;
      final items = await serviceRepository.fetchTrending(limit: 8);
      trending.assignAll(items);
    } catch (e) {
      error.value = e.toString();
      trending.clear();
    } finally {
      trendingLoading.value = false;
    }
  }

  Future<void> _loadNearby() async {
    try {
      nearbyLoading.value = true;
      error.value = null;
      final user = userStore.value;
      double? lat = user?.latitude;
      double? lng = user?.longitude;

      // Fall back to live location if profile lacks coords
      if (lat == null || lng == null) {
        final position = await locationService.getCurrentPosition();
        lat = position.latitude;
        lng = position.longitude;
      }

      userLat = lat;
      userLng = lng;
      hasLocation.value = true;
      final items = await serviceRepository.fetchNearby(
        latitude: lat,
        longitude: lng,
        limit: 20,
        radiusKm: 50,
      );
      // Filter to show only venues
      nearby.assignAll(
        items
            .where(
              (service) => service.categories.any((cat) => cat.id == 'venue'),
            )
            .toList(),
      );
    } catch (e) {
      error.value = e.toString();
      nearby.clear();
    } finally {
      nearbyLoading.value = false;
    }
  }

  Future<void> _loadMyServices() async {
    final user = userStore.value;
    if (user == null || !(user.isProvider || user.role == 'provider')) {
      myServices.clear();
      return;
    }
    try {
      myServicesLoading.value = true;
      _myServicesStream ??= serviceRepository.streamProviderServices(user.id);
      _myServicesSub?.cancel();
      _myServicesSub = _myServicesStream!.listen((items) {
        myServices.assignAll(items);
      });
    } catch (e) {
      error.value = e.toString();
      myServices.clear();
    } finally {
      myServicesLoading.value = false;
    }
  }
}
