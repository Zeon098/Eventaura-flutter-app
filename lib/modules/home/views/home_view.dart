import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/stores/user_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/service_repository.dart';
import '../../notifications/views/notification_list_view.dart';
import '../../services/views/service_explore_view.dart';
import '../components/horizontal_services_list.dart';
import '../components/search_bar_home.dart';
import '../components/section_header.dart';
import '../components/welcome_header.dart';
import '../controllers/home_controller.dart';
import 'map_view.dart';

class HomeView extends GetView {
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
    // homeController.onInit();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Discover',
          style: TextStyle(
            color: AppTheme.textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_outlined,
                color: AppTheme.primaryColor,
              ),
              onPressed: () => Get.to(() => const NotificationListView()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([homeController.loadTrending()]);
        },
        color: AppTheme.primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              // Welcome Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: WelcomeHeader(userName: user?.displayName),
              ),
              const SizedBox(height: 20),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SearchBarHome(
                  onTap: () => Get.to(() => const ServiceExploreView()),
                ),
              ),
              const SizedBox(height: 32),

              // Your Services Section (Provider only)
              if (user != null && (user.isProvider || user.role == 'provider'))
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Obx(
                          () => SectionHeader(
                            title: 'Your Services',
                            icon: Icons.work_outline_rounded,
                            trailing: homeController.myServicesLoading.value
                                ? SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.primaryColor,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Obx(() {
                        final items = homeController.myServices;
                        if (items.isEmpty) {
                          return const EmptyServicesState(
                            message: 'You have no services yet.',
                            icon: Icons.work_off_outlined,
                          );
                        }
                        return HorizontalServicesList(services: items);
                      }),
                    ],
                  ),
                ),

              // Trending Services Section
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Obx(
                        () => SectionHeader(
                          title: 'Trending Services',
                          icon: Icons.trending_up_rounded,
                          trailing: homeController.trendingLoading.value
                              ? SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppTheme.primaryColor,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),
                    ),
                    Obx(() {
                      final items = homeController.trending;
                      if (items.isEmpty) {
                        return const EmptyServicesState(
                          message: 'No trending services right now.',
                          icon: Icons.trending_up_rounded,
                        );
                      }
                      return HorizontalServicesList(services: items);
                    }),
                  ],
                ),
              ),

              // Nearby Services Section
              Obx(() {
                final hasLocation = homeController.hasLocation.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: SectionHeader(
                          title: 'Nearby Services',
                          icon: Icons.location_on_rounded,
                          trailing: Container(
                            decoration: BoxDecoration(
                              color: hasLocation
                                  ? AppTheme.primaryColor
                                  : AppTheme.dividerColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: hasLocation
                                  ? [
                                      BoxShadow(
                                        color: AppTheme.primaryColor
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.map_rounded,
                                color: hasLocation ? Colors.white : Colors.grey,
                                size: 20,
                              ),
                              tooltip: 'View on map',
                              onPressed: hasLocation
                                  ? () {
                                      Get.to(
                                        () => const MapView(),
                                        arguments: {
                                          'services':
                                              homeController.nearby.toList(),
                                          'center': {
                                            'lat': homeController.userLat ??
                                                0,
                                            'lng': homeController.userLng ??
                                                0,
                                          },
                                        },
                                      );
                                    }
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      Obx(() {
                        if (homeController.nearbyLoading.value) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            padding: const EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          );
                        }
                        final items = homeController.nearby;
                        if (items.isEmpty) {
                          return const EmptyServicesState(
                            message:
                                'Location unavailable or no services nearby.',
                            icon: Icons.location_off_rounded,
                          );
                        }
                        return HorizontalServicesList(services: items);
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
