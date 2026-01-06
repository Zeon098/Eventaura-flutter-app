import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../components/explore/category_chips.dart';
import '../components/explore/empty_state.dart';
import '../components/explore/gradient_app_bar.dart';
import '../components/explore/loading_state.dart';
import '../components/explore/price_range_filter.dart';
import '../components/explore/search_bar_widget.dart';
import '../components/explore/service_card.dart';
import '../controllers/algolia_search_controller.dart';
import '../controllers/service_controller.dart';

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

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category == 'All' ? '' : category;
    });
    _triggerSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          const GradientAppBar(),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  SearchBarWidget(
                    controller: _queryController,
                    onChanged: _onQueryChanged,
                    onClear: () {
                      setState(() {
                        _queryController.clear();
                      });
                      _triggerSearch();
                    },
                    hasText: _queryController.text.isNotEmpty,
                  ),
                  const SizedBox(height: 20),
                  Obx(() {
                    final categories = {
                      'All',
                      ...serviceController.services.expand(
                        (s) => s.categories.isNotEmpty
                            ? s.categories.map((c) => c.name)
                            : [s.category],
                      ),
                    }.toList();
                    return CategoryChips(
                      categories: categories,
                      selectedCategory: _selectedCategory,
                      onCategorySelected: _onCategorySelected,
                    );
                  }),
                  const SizedBox(height: 20),
                  PriceRangeFilter(
                    priceRange: _priceRange,
                    onChanged: _triggerSearch,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: Obx(() {
              final loading = _isFiltering && searchController.isLoading.value;
              final items = _isFiltering
                  ? searchController.results
                  : serviceController.services;

              if (loading) {
                return const SliverToBoxAdapter(child: LoadingState());
              }

              if (items.isEmpty) {
                return const SliverToBoxAdapter(child: EmptyState());
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final service = items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: ServiceCard(service: service),
                  );
                }, childCount: items.length),
              );
            }),
          ),
        ],
      ),
    );
  }
}
