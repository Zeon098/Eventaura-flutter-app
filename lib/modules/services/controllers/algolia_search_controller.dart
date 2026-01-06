import 'package:algolia/algolia.dart';
import 'package:get/get.dart';
import '../../../core/services/algolia_service.dart';
import '../../../data/models/service_model.dart';

class AlgoliaSearchController extends GetxController {
  AlgoliaSearchController({AlgoliaService? algoliaService})
    : _algolia = algoliaService ?? AlgoliaService();

  final AlgoliaService _algolia;
  final results = <ServiceModel>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  Future<void> searchByKeyword(
    String keyword, {
    double? minPrice,
    double? maxPrice,
    String? category,
  }) async {
    await _runSearch(
      (index) => _applyFilters(
        index.query(keyword.trim()),
        minPrice: minPrice,
        maxPrice: maxPrice,
        category: category,
      ),
    );
  }

  Future<void> searchByCategory(
    String category, {
    String keyword = '',
    double? minPrice,
    double? maxPrice,
  }) async {
    await _runSearch(
      (index) => _applyFilters(
        index.query(keyword.trim()),
        minPrice: minPrice,
        maxPrice: maxPrice,
        category: category,
      ),
    );
  }

  Future<void> searchByLocation(
    double latitude,
    double longitude, {
    String keyword = '',
    double? radiusKm,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    await _runSearch((index) {
      var query = index.query(keyword.trim());
      query = query.setAroundLatLng('$latitude,$longitude');
      if (radiusKm != null) {
        query = query.setAroundRadius((radiusKm * 1000).round());
      }
      return _applyFilters(
        query,
        minPrice: minPrice,
        maxPrice: maxPrice,
        category: category,
      );
    });
  }

  Future<void> _runSearch(
    AlgoliaQuery Function(AlgoliaIndexReference index) builder,
  ) async {
    try {
      isLoading.value = true;
      error.value = null;
      final index = _algolia.serviceIndex();
      final query = builder(index);
      final response = await query.getObjects();
      final hits = response.hits;
      results.assignAll(hits.map((snap) => _fromHit(snap.data)));
    } catch (e) {
      error.value = e.toString();
      results.clear();
    } finally {
      isLoading.value = false;
    }
  }

  AlgoliaQuery _applyFilters(
    AlgoliaQuery query, {
    double? minPrice,
    double? maxPrice,
    String? category,
  }) {
    final filters = <String>[];
    if (minPrice != null) filters.add('price >= $minPrice');
    if (maxPrice != null) filters.add('price <= $maxPrice');
    if (category != null && category.isNotEmpty) {
      filters.add('(categories:"$category" OR category:"$category")');
    }
    if (filters.isNotEmpty) {
      query = query.setFilters(filters.join(' AND '));
    }
    return query;
  }

  ServiceModel _fromHit(Map<String, dynamic> hit) {
    final geo = hit['_geoloc'];
    final categories = hit['categories'];
    return ServiceModel(
      id: hit['objectID'] ?? '',
      providerId: hit['providerId'] ?? '',
      title: hit['title'] ?? '',
      categories: categories is Iterable
          ? List<String>.from(categories)
          : hit['category'] != null
          ? [hit['category']]
          : <String>[],
      price: (hit['price'] as num?)?.toDouble() ?? 0,
      description: hit['description'] ?? '',
      location: hit['location'] ?? '',
      latitude: (geo is Map && geo['lat'] is num)
          ? (geo['lat'] as num).toDouble()
          : null,
      longitude: (geo is Map && geo['lng'] is num)
          ? (geo['lng'] as num).toDouble()
          : null,
      coverImage: hit['cover_image'] ?? '',
      galleryImages: List<String>.from(hit['gallery_images'] ?? const []),
      rating: (hit['rating'] as num?)?.toDouble() ?? 0,
    );
  }
}
