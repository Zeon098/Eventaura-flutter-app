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
  ServiceCategory? _selectedCategory;

  ServiceCategory? _findCategoryById(String? id) {
    if (id == null) return null;
    for (final c in service.categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['service'] is ServiceModel) {
      service = args['service'] as ServiceModel;
      final catId = args['categoryId'] as String?;
      _selectedCategory = _findCategoryById(catId) ?? service.primaryCategory;
    } else {
      service = args as ServiceModel;
      _selectedCategory = service.primaryCategory;
    }
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
                      ServiceTitleSection(
                        service: service,
                        selectedCategory: _selectedCategory,
                      ),
                      const SizedBox(height: 12),
                      if (service.categories.isNotEmpty)
                        _CategorySelector(
                          categories: service.categories,
                          selected: _selectedCategory,
                          onSelect: (c) => setState(() {
                            _selectedCategory = c;
                          }),
                        ),
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
                        selectedCategory: _selectedCategory,
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

class _CategorySelector extends StatelessWidget {
  const _CategorySelector({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  final List<ServiceCategory> categories;
  final ServiceCategory? selected;
  final ValueChanged<ServiceCategory> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final isSelected = selected?.id == c.id;
        return ChoiceChip(
          label: Text('${c.name} — PKR ${c.price.toStringAsFixed(0)}'),
          selected: isSelected,
          onSelected: (_) => onSelect(c),
          selectedColor: AppTheme.primaryColor.withOpacity(0.15),
          labelStyle: TextStyle(
            color: isSelected
                ? AppTheme.primaryColor
                : AppTheme.textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}
