import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/stores/user_store.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../home/controllers/shell_controller.dart';
import '../components/service_header.dart';
import '../components/gallery_strip.dart';
import '../components/service_title_section.dart';
import '../components/category_rating_row.dart';
import '../components/service_description.dart';
import '../components/provider_section.dart';
import '../components/location_section.dart';
import '../components/book_button.dart';

class ServiceDetailView extends StatefulWidget {
  const ServiceDetailView({super.key});

  @override
  State<ServiceDetailView> createState() => _ServiceDetailViewState();
}

class _ServiceDetailViewState extends State<ServiceDetailView> {
  late final ServiceModel service;
  late final BookingController bookingController;

  @override
  void initState() {
    super.initState();
    service = Get.arguments as ServiceModel;
    bookingController = Get.put(
      BookingController(
        bookingRepository: Get.find(),
        chatRepository: Get.find(),
        userRepository: Get.find<UserRepository>(),
        notificationService: Get.find(),
        userStore: Get.find(),
      ),
      tag: service.id,
    );
  }

  @override
  void dispose() {
    Get.delete<BookingController>(tag: service.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    final userStore = Get.find<UserStore>();
    final gallery = service.galleryImages.take(5).toList();
    final userId = userStore.value?.id ?? shell.user.value?.id ?? '';

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: CustomScrollView(
        slivers: [
          ServiceHeader(service: service),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (gallery.isNotEmpty) GalleryStrip(images: gallery),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ServiceTitleSection(service: service),
                      const SizedBox(height: 16),
                      CategoryRatingRow(service: service),
                      const SizedBox(height: 20),
                      ServiceDescription(service: service),
                      const SizedBox(height: 24),
                      ProviderSection(
                        providerFuture: Get.find<UserRepository>().fetchUser(
                          service.providerId,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LocationSection(service: service),
                      const SizedBox(height: 32),
                      BookButton(
                        service: service,
                        bookingController: bookingController,
                        userId: userId,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
