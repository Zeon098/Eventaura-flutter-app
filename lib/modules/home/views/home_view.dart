import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/stores/user_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/service_repository.dart';
import '../../notifications/views/notification_list_view.dart';
import '../../services/views/service_explore_view.dart';
import '../../services/views/service_detail_view.dart';
import '../controllers/home_controller.dart';
import 'map_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final userStore = Get.find<UserStore>();
    final user = userStore.value;
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(
            HomeController(
              serviceRepository: Get.find<ServiceRepository>(),
              locationService: Get.find(),
              userStore: userStore,
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Get.to(() => const NotificationListView()),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([homeController.loadTrending()]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchBar(onTap: () => Get.to(() => const ServiceExploreView())),
              const SizedBox(height: 16),
              if (user != null && (user.isProvider || user.role == 'provider'))
                Obx(
                  () => _Section(
                    title: 'Your Services',
                    trailing: homeController.myServicesLoading.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : null,
                    child: Obx(() {
                      final items = homeController.myServices;
                      if (items.isEmpty) {
                        return const Text('You have no services yet.');
                      }
                      return _HorizontalServices(services: items);
                    }),
                  ),
                ),
              _Section(
                title: 'Trending Services',
                trailing: Obx(
                  () => homeController.trendingLoading.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const SizedBox.shrink(),
                ),
                child: Obx(() {
                  final items = homeController.trending;
                  if (items.isEmpty) {
                    return const Text('No trending services right now.');
                  }
                  return _HorizontalServices(services: items);
                }),
              ),
              Obx(() {
                final hasLocation = homeController.hasLocation.value;
                return _Section(
                  title: 'Nearby Services',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.map_outlined),
                        tooltip: 'View on map',
                        onPressed: hasLocation
                            ? () {
                                Get.to(
                                  () => const MapView(),
                                  arguments: {
                                    'services': homeController.nearby.toList(),
                                    'center':
                                        homeController.userLatLng ??
                                        const LatLng(0, 0),
                                  },
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                  child: Obx(() {
                    if (homeController.nearbyLoading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final items = homeController.nearby;
                    if (items.isEmpty) {
                      return const Text(
                        'Location unavailable or no services nearby.',
                      );
                    }
                    return _HorizontalServices(services: items);
                  }),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _HorizontalServices extends StatelessWidget {
  const _HorizontalServices({required this.services});

  final List<ServiceModel> services;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: services.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final service = services[index];
          return SizedBox(width: 200, child: _ServiceCard(service: service));
        },
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final ServiceModel service;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const ServiceDetailView(), arguments: service),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: service.coverImage.isNotEmpty
                    ? Image.network(
                        service.coverImage,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(color: AppColors.primary.withOpacity(0.1)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'PKR ${service.price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search services',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
