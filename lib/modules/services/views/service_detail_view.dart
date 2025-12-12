import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../home/controllers/shell_controller.dart';

class ServiceDetailView extends StatelessWidget {
  const ServiceDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final service = Get.arguments as ServiceModel;
    final shell = Get.find<ShellController>();
    final bookingController = Get.put(
      BookingController(
        bookingRepository: Get.find(),
        chatRepository: Get.find(),
      ),
    );
    final gallery = service.galleryImages;
    return Scaffold(
      appBar: AppBar(title: Text(service.title)),
      body: ListView(
        children: [
          CachedNetworkImage(
            imageUrl: service.coverImage,
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          if (gallery.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(12),
                itemCount: gallery.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: gallery[index],
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      '${service.rating.toStringAsFixed(1)} • PKR ${service.price.toStringAsFixed(0)}',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Location: ${service.location}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Obx(
                  () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    onPressed: bookingController.isLoading.value
                        ? null
                        : () async {
                            final userId = shell.user.value?.id;
                            if (userId == null) return;
                            await bookingController.createBooking(
                              serviceId: service.id,
                              consumerId: userId,
                              providerId: service.providerId,
                            );
                          },
                    child: bookingController.isLoading.value
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Book now'),
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
