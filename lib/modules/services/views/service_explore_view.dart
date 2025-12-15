import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/algolia_search_controller.dart';
import '../controllers/service_controller.dart';
import 'service_detail_view.dart';

class ServiceExploreView extends StatefulWidget {
  const ServiceExploreView({super.key});

  @override
  State<ServiceExploreView> createState() => _ServiceExploreViewState();
}

class _ServiceExploreViewState extends State<ServiceExploreView> {
  late final ServiceController serviceController;
  late final AlgoliaSearchController searchController;
  final _queryController = TextEditingController();
  final _priceRange = ValueNotifier(const RangeValues(0, 100000));
  Timer? _debounce;
  String _selectedCategory = '';

  bool get _isFiltering {
    final defaultRange = const RangeValues(0, 100000);
    return _queryController.text.trim().isNotEmpty ||
        _selectedCategory.isNotEmpty ||
        _priceRange.value != defaultRange;
  }

  @override
  void initState() {
    super.initState();
    serviceController = Get.put(
      ServiceController(
        serviceRepository: Get.find(),
        locationService: Get.find(),
        userStore: Get.find(),
      ),
    );
    searchController = Get.put(AlgoliaSearchController());
    serviceController.bindAllServices();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    _priceRange.dispose();
    super.dispose();
  }

  void _triggerSearch() {
    if (!_isFiltering) {
      searchController.results.clear();
      return;
    }
    final minPrice = _priceRange.value.start > 0
        ? _priceRange.value.start
        : null;
    final maxPrice = _priceRange.value.end < 100000
        ? _priceRange.value.end
        : null;
    searchController.searchByKeyword(
      _queryController.text,
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: _selectedCategory.isNotEmpty ? _selectedCategory : null,
    );
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _triggerSearch);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Services')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _queryController,
                  onChanged: _onQueryChanged,
                  decoration: InputDecoration(
                    hintText: 'Search services',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 42,
                  child: Obx(() {
                    final categories = {
                      'All',
                      ...serviceController.services.map((s) => s.category),
                    }.toList();
                    return ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, index) {
                        final label = categories[index];
                        final selected =
                            (label == 'All' && _selectedCategory.isEmpty) ||
                            (_selectedCategory == label);
                        return ChoiceChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedCategory = label == 'All' ? '' : label;
                            });
                            _triggerSearch();
                          },
                        );
                      },
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Price range'),
                    ValueListenableBuilder(
                      valueListenable: _priceRange,
                      builder: (_, RangeValues range, __) {
                        return Text(
                          'PKR ${range.start.toStringAsFixed(0)} - ${range.end.toStringAsFixed(0)}',
                        );
                      },
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable: _priceRange,
                  builder: (_, RangeValues range, __) {
                    return RangeSlider(
                      values: range,
                      min: 0,
                      max: 100000,
                      divisions: 20,
                      labels: RangeLabels(
                        'PKR ${range.start.toStringAsFixed(0)}',
                        'PKR ${range.end.toStringAsFixed(0)}',
                      ),
                      onChanged: (v) {
                        _priceRange.value = v;
                        _triggerSearch();
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final loading = _isFiltering && searchController.isLoading.value;
              final items = _isFiltering
                  ? searchController.results
                  : serviceController.services;

              if (loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (items.isEmpty) {
                return const Center(child: Text('No services found'));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, index) {
                  final service = items[index];
                  return Container(
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
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: service.coverImage,
                          width: 54,
                          height: 54,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: Colors.grey.shade200),
                          errorWidget: (_, __, ___) =>
                              Container(color: Colors.grey.shade300),
                        ),
                      ),
                      title: Text(service.title),
                      subtitle: Text(
                        '${service.category} • PKR ${service.price.toStringAsFixed(0)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Get.to(
                        () => const ServiceDetailView(),
                        arguments: service,
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
