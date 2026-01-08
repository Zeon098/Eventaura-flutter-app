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
  final Set<ServiceCategory> _selectedCategories = {};

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
      final first = _findCategoryById(catId) ?? service.primaryCategory;
      if (first != null) _selectedCategories.add(first);
    } else {
      service = args as ServiceModel;
      if (service.primaryCategory != null) {
        _selectedCategories.add(service.primaryCategory!);
      }
    }
    // Use existing controller if available to maintain stream connections
    if (Get.isRegistered<BookingController>()) {
      bookingController = Get.find<BookingController>();
    } else {
      bookingController = Get.put(
        BookingController(
          bookingRepository: Get.find(),
          chatRepository: Get.find(),
          userRepository: Get.find<UserRepository>(),
          notificationService: Get.find(),
          userStore: Get.find(),
        ),
      );
    }
  }

  @override
  void dispose() {
    // Don't delete the global controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    final userStore = Get.find<UserStore>();
    final gallery = service.galleryImages.take(5).toList();
    final userId = userStore.value?.id ?? shell.user.value?.id ?? '';
    final totalPrice = _selectedCategories.fold<double>(
      0,
      (sum, c) => sum + c.price,
    );
    final showBookButton = userId.isEmpty || userId != service.providerId;

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
                        selectedCategory: _selectedCategories.isNotEmpty
                            ? _selectedCategories.first
                            : null,
                        priceOverride: _selectedCategories.isNotEmpty
                            ? totalPrice
                            : null,
                      ),
                      const SizedBox(height: 12),
                      if (service.categories.isNotEmpty)
                        _CategorySelector(
                          categories: service.categories,
                          selected: _selectedCategories,
                          onToggle: (c) => setState(() {
                            if (_selectedCategories.contains(c) &&
                                _selectedCategories.length > 1) {
                              _selectedCategories.remove(c);
                            } else {
                              _selectedCategories.add(c);
                            }
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
                      if (showBookButton)
                        BookButton(
                          service: service,
                          bookingController: bookingController,
                          userId: userId,
                          selectedCategories: _selectedCategories.toList(),
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
    required this.onToggle,
  });

  final List<ServiceCategory> categories;
  final Set<ServiceCategory> selected;
  final ValueChanged<ServiceCategory> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final isSelected = selected.any((s) => s.id == c.id);
        return ChoiceChip(
          label: Text('${c.name} — PKR ${c.price.toStringAsFixed(0)}'),
          selected: isSelected,
          onSelected: (_) => onToggle(c),
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
