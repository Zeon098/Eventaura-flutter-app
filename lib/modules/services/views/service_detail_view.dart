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
  final Map<String, int> _categoryQuantities = {}; // category id -> quantity

  ServiceCategory? _findCategoryById(String? id) {
    if (id == null) return null;
    for (final c in service.categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  double _calculateCategoryPrice(ServiceCategory category) {
    final quantity = _categoryQuantities[category.id] ?? 1;
    final pricingType = category.pricingType ?? 'base';

    switch (pricingType) {
      case 'per_head':
        return category.price * quantity;
      case 'per_100_persons':
        return category.price * (quantity / 100);
      case 'base':
      default:
        return category.price;
    }
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
      (sum, c) => sum + _calculateCategoryPrice(c),
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
                      // Venue Subtypes
                      if (service.venueSubtypes != null &&
                          service.venueSubtypes!.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Venue Types',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: service.venueSubtypes!.map((subtype) {
                            return Chip(
                              label: Text(subtype),
                              backgroundColor: AppTheme.primaryColor
                                  .withOpacity(0.1),
                              labelStyle: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      // Quantity Inputs for Selected Categories
                      if (_selectedCategories.any(
                        (c) =>
                            c.pricingType == 'per_head' ||
                            c.pricingType == 'per_100_persons',
                      )) ...[
                        const SizedBox(height: 20),
                        const Text(
                          'Quantity',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._selectedCategories
                            .where(
                              (c) =>
                                  c.pricingType == 'per_head' ||
                                  c.pricingType == 'per_100_persons',
                            )
                            .map((category) {
                              return _QuantityInput(
                                category: category,
                                quantity: _categoryQuantities[category.id] ?? 1,
                                onChanged: (value) => setState(() {
                                  _categoryQuantities[category.id] = value;
                                }),
                                calculatedPrice: _calculateCategoryPrice(
                                  category,
                                ),
                              );
                            }),
                      ],
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

  String _getPricingTypeLabel(String? pricingType) {
    switch (pricingType) {
      case 'per_head':
        return 'per person';
      case 'per_100_persons':
        return 'per 100 persons';
      case 'base':
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((c) {
        final isSelected = selected.any((s) => s.id == c.id);
        final pricingLabel = _getPricingTypeLabel(c.pricingType);
        return ChoiceChip(
          label: Text(
            '${c.name} — PKR ${c.price.toStringAsFixed(0)}${pricingLabel.isNotEmpty ? ' ($pricingLabel)' : ''}',
          ),
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

class _QuantityInput extends StatefulWidget {
  const _QuantityInput({
    required this.category,
    required this.quantity,
    required this.onChanged,
    required this.calculatedPrice,
  });

  final ServiceCategory category;
  final int quantity;
  final ValueChanged<int> onChanged;
  final double calculatedPrice;

  @override
  State<_QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<_QuantityInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quantity.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(_QuantityInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.quantity != oldWidget.quantity && !_focusNode.hasFocus) {
      _controller.text = widget.quantity.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndUpdate();
    }
  }

  void _validateAndUpdate() {
    final value = int.tryParse(_controller.text);
    if (value == null || value < 1) {
      _controller.text = widget.quantity.toString();
    } else if (value != widget.quantity) {
      widget.onChanged(value);
    }
  }

  String get _quantityLabel {
    if (widget.category.pricingType == 'per_100_persons') {
      return 'Number of People';
    }
    return 'Number of People';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.category.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Base: PKR ${widget.category.price.toStringAsFixed(0)} ${widget.category.pricingType == 'per_head' ? 'per person' : 'per 100 persons'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'PKR ${widget.calculatedPrice.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  _quantityLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.dividerColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: widget.quantity > 1
                          ? () {
                              widget.onChanged(widget.quantity - 1);
                              _controller.text = (widget.quantity - 1)
                                  .toString();
                            }
                          : null,
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _validateAndUpdate(),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        widget.onChanged(widget.quantity + 1);
                        _controller.text = (widget.quantity + 1).toString();
                      },
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
