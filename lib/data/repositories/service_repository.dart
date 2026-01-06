import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/services/algolia_service.dart';
import '../../core/services/cloudinary_service.dart';
import '../../core/utils/app_constants.dart';
import '../models/service_model.dart';

class ServiceRepository {
  ServiceRepository({
    FirebaseFirestore? firestore,
    CloudinaryService? cloudinaryService,
    AlgoliaService? algoliaService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudinary = cloudinaryService ?? CloudinaryService(),
       _algolia = algoliaService ?? AlgoliaService();

  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinary;
  final AlgoliaService _algolia;
  final _uuid = const Uuid();

  Future<ServiceModel> createService({
    required String providerId,
    required String title,
    required List<ServiceCategory> categories,
    required String description,
    required String location,
    required File cover,
    List<File> gallery = const [],
    double? latitude,
    double? longitude,
  }) async {
    final coverUrl = await _cloudinary.uploadImage(
      cover,
      folder: 'services/covers',
    );
    final galleryUrls = <String>[];
    for (final img in gallery.take(5)) {
      galleryUrls.add(
        await _cloudinary.uploadImage(img, folder: 'services/gallery'),
      );
    }
    final id = _uuid.v4();
    final service = ServiceModel(
      id: id,
      providerId: providerId,
      title: title,
      categories: categories,
      description: description,
      location: location,
      coverImage: coverUrl,
      galleryImages: galleryUrls,
      latitude: latitude,
      longitude: longitude,
    );
    await _firestore
        .collection(AppConstants.servicesCollection)
        .doc(id)
        .set(service.toMap());
    await _indexService(service);
    return service;
  }

  Future<void> updateService(
    ServiceModel service, {
    File? newCover,
    List<File> newGallery = const [],
  }) async {
    String coverUrl = service.coverImage;
    if (newCover != null) {
      coverUrl = await _cloudinary.uploadImage(
        newCover,
        folder: 'services/covers',
      );
    }

    List<String> galleryUrls = service.galleryImages;
    if (newGallery.isNotEmpty) {
      galleryUrls = [];
      for (final img in newGallery.take(5)) {
        galleryUrls.add(
          await _cloudinary.uploadImage(img, folder: 'services/gallery'),
        );
      }
    }

    final updated = service.copyWith(
      coverImage: coverUrl,
      galleryImages: galleryUrls,
    );
    await _firestore
        .collection(AppConstants.servicesCollection)
        .doc(service.id)
        .update(updated.toMap());
    await _indexService(updated);
  }

  Future<void> deleteService(String id) async {
    await _firestore
        .collection(AppConstants.servicesCollection)
        .doc(id)
        .delete();
    // Remove from Algolia index; ignore if it does not exist there yet.
    try {
      await _algolia.serviceIndex(admin: true).object(id).deleteObject();
    } catch (_) {}
  }

  Future<List<ServiceModel>> fetchTrending({int limit = 10}) async {
    final index = _algolia.serviceIndex();
    final response = await index.query('').setHitsPerPage(limit).getObjects();
    return response.hits.map((hit) => _fromHit(hit.data)).toList();
  }

  Future<List<ServiceModel>> fetchNearby({
    required double latitude,
    required double longitude,
    int limit = 20,
    double? radiusKm,
  }) async {
    var query = _algolia
        .serviceIndex()
        .query('')
        .setAroundLatLng('$latitude,$longitude')
        .setHitsPerPage(limit);

    if (radiusKm != null) {
      query = query.setAroundRadius((radiusKm * 1000).round());
    }

    final response = await query.getObjects();
    return response.hits
        .map((hit) => _fromHit(hit.data))
        .where((s) => s.latitude != null && s.longitude != null)
        .toList();
  }

  Future<List<ServiceModel>> fetchProviderServices(String providerId) async {
    final snap = await _firestore
        .collection(AppConstants.servicesCollection)
        .where('providerId', isEqualTo: providerId)
        .get();
    return snap.docs.map((d) => ServiceModel.fromMap(d.id, d.data())).toList();
  }

  Future<ServiceModel?> getService(String id) async {
    final doc = await _firestore
        .collection(AppConstants.servicesCollection)
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return ServiceModel.fromMap(doc.id, doc.data() ?? {});
  }

  Stream<List<ServiceModel>> streamAllServices() {
    return _firestore
        .collection(AppConstants.servicesCollection)
        .orderBy('rating', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ServiceModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Stream<List<ServiceModel>> streamProviderServices(String providerId) {
    return _firestore
        .collection(AppConstants.servicesCollection)
        .where('providerId', isEqualTo: providerId)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ServiceModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<void> _indexService(ServiceModel service) async {
    final payload = {
      'objectID': service.id,
      'providerId': service.providerId,
      'title': service.title,
      'description': service.description,
      'categories': service.categories.map((c) => c.toMap()).toList(),
      'category': service.primaryCategory?.id ?? '',
      'categoryPrices': {for (final c in service.categories) c.id: c.price},
      'categoryTokens': [
        ...service.categories.map((c) => c.id),
        ...service.categories.map((c) => c.name),
      ],
      'price': service.primaryPrice,
      'rating': service.rating,
      'location': service.location,
      'cover_image': service.coverImage,
      'gallery_images': service.galleryImages.take(5).toList(),
    };

    if (service.latitude != null && service.longitude != null) {
      // Algolia expects _geoloc for geo queries.
      payload['_geoloc'] = {'lat': service.latitude, 'lng': service.longitude};
    }

    await _algolia.serviceIndex(admin: true).addObject(payload);
  }

  ServiceModel _fromHit(Map<String, dynamic> hit) {
    final geo = hit['_geoloc'];

    final mapped = <String, dynamic>{
      'providerId': hit['providerId'] ?? '',
      'title': hit['title'] ?? '',
      'categories': hit['categories'],
      'category': hit['category'],
      'price': hit['price'],
      'description': hit['description'] ?? '',
      'location': hit['location'] ?? '',
      'latitude': (geo is Map && geo['lat'] is num)
          ? (geo['lat'] as num).toDouble()
          : null,
      'longitude': (geo is Map && geo['lng'] is num)
          ? (geo['lng'] as num).toDouble()
          : null,
      'coverImage': hit['cover_image'] ?? '',
      'galleryImages': List<String>.from(hit['gallery_images'] ?? const []),
      'rating': (hit['rating'] as num?)?.toDouble() ?? 0,
      'categoryPrices': hit['categoryPrices'],
    };

    return ServiceModel.fromMap(hit['objectID'] ?? '', mapped);
  }
}
