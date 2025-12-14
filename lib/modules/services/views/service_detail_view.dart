import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/stores/user_store.dart';
import '../../booking/controllers/booking_controller.dart';
import '../../home/controllers/shell_controller.dart';

class ServiceDetailView extends StatefulWidget {
  const ServiceDetailView({super.key});

  @override
  State<ServiceDetailView> createState() => _ServiceDetailViewState();
}

class _ServiceDetailViewState extends State<ServiceDetailView> {
  late final ServiceModel service;
  late final Future<AppUser> providerFuture;
  late final BookingController bookingController;

  @override
  void initState() {
    super.initState();
    service = Get.arguments as ServiceModel;
    providerFuture = Get.find<UserRepository>().fetchUser(service.providerId);
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
    final mapUrl = _buildMapUrl(service.latitude, service.longitude);

    return Scaffold(
      appBar: AppBar(title: Text(service.title)),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          _coverImage(service.coverImage),
          if (gallery.isNotEmpty) _galleryStrip(gallery),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _titlePriceRow(context),
                const SizedBox(height: 8),
                _categoryRatingRow(),
                const SizedBox(height: 12),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                _providerSection(),
                const SizedBox(height: 20),
                _locationSection(mapUrl),
                const SizedBox(height: 28),
                Obx(
                  () => ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: bookingController.isLoading.value
                        ? null
                        : () async {
                            final userId =
                                userStore.value?.id ?? shell.user.value?.id;
                            if (userId == null) return;
                            await bookingController.createBooking(
                              serviceId: service.id,
                              consumerId: userId,
                              providerId: service.providerId,
                              serviceTitle: service.title,
                            );
                          },
                    icon: bookingController.isLoading.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.calendar_month),
                    label: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverImage(String url) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey.shade200),
        errorWidget: (_, __, ___) => Container(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _galleryStrip(List<String> images) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(12),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, index) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: images[index],
            width: 120,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (_, __) =>
                Container(width: 120, height: 100, color: Colors.grey[200]),
            errorWidget: (_, __, ___) =>
                Container(width: 120, height: 100, color: Colors.grey[300]),
          ),
        ),
      ),
    );
  }

  Widget _titlePriceRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            service.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Text(
          'PKR ${service.price.toStringAsFixed(0)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _categoryRatingRow() {
    return Row(
      children: [
        Chip(
          label: Text(service.category),
          backgroundColor: Colors.grey.shade100,
        ),
        const SizedBox(width: 12),
        const Icon(Icons.star, color: Colors.amber, size: 18),
        const SizedBox(width: 4),
        Text(service.rating.toStringAsFixed(1)),
      ],
    );
  }

  Widget _providerSection() {
    return FutureBuilder<AppUser>(
      future: providerFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SectionCard(child: LinearProgressIndicator());
        }
        if (!snapshot.hasData) {
          return const _SectionCard(child: Text('Provider info unavailable'));
        }
        final provider = snapshot.data!;
        return _SectionCard(
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: provider.photoUrl != null
                    ? NetworkImage(provider.photoUrl!)
                    : null,
                child: provider.photoUrl == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.displayName ?? 'Provider',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    Text(provider.email),
                    if (provider.city != null)
                      Text(
                        provider.city!,
                        style: const TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () =>
                    Get.to(() => ProviderProfileView(providerId: provider.id)),
                child: const Text('View profile'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _locationSection(String? mapUrl) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(service.location),
            ],
          ),
          const SizedBox(height: 12),
          if (mapUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: mapUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(height: 180, color: Colors.grey.shade200),
                errorWidget: (_, __, ___) =>
                    Container(height: 180, color: Colors.grey.shade300),
              ),
            )
          else
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              alignment: Alignment.center,
              child: const Text('Map preview unavailable'),
            ),
          const SizedBox(height: 8),
          if (service.latitude != null && service.longitude != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    _openMaps(service.latitude!, service.longitude!),
                icon: const Icon(Icons.map_outlined),
                label: const Text('Open in Maps'),
              ),
            ),
        ],
      ),
    );
  }

  String? _buildMapUrl(double? lat, double? lng) {
    if (lat == null || lng == null) return null;
    final center = '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
    return 'https://staticmap.openstreetmap.de/staticmap.php?center=$center&zoom=14&size=600x300&markers=$center,red-pushpin';
  }

  Future<void> _openMaps(double lat, double lng) async {
    final googleUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(googleUri)) {
      await launchUrl(googleUri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProviderProfileView extends StatelessWidget {
  const ProviderProfileView({super.key, required this.providerId});

  final String providerId;

  @override
  Widget build(BuildContext context) {
    final userRepo = Get.find<UserRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Profile')),
      body: FutureBuilder<AppUser>(
        future: userRepo.fetchUser(providerId),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Provider not found'));
          }
          final provider = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: provider.photoUrl != null
                      ? NetworkImage(provider.photoUrl!)
                      : null,
                  child: provider.photoUrl == null
                      ? const Icon(Icons.person, size: 38)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  provider.displayName ?? 'Provider',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(provider.email),
                if (provider.city != null)
                  Text(
                    provider.city!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
