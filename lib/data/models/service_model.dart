import 'package:equatable/equatable.dart';

class ServiceCategory extends Equatable {
  final String id;
  final String name;
  final double price;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toMap() => {'id': id, 'name': name, 'price': price};

  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, price];
}

class ServiceModel extends Equatable {
  final String id;
  final String providerId;
  final String title;
  final List<ServiceCategory> categories;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final String coverImage;
  final List<String> galleryImages;
  final double rating;
  final double? legacyPrice; // retained for backwards compatibility

  const ServiceModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.categories,
    required this.description,
    required this.location,
    required this.coverImage,
    required this.galleryImages,
    this.latitude,
    this.longitude,
    this.rating = 0,
    this.legacyPrice,
  });

  ServiceCategory? get primaryCategory =>
      categories.isNotEmpty ? categories.first : null;

  double get primaryPrice => primaryCategory?.price ?? legacyPrice ?? 0;
  String get primaryCategoryId => primaryCategory?.id ?? '';
  String get primaryCategoryName => primaryCategory?.name ?? '';
  String get category => primaryCategoryName; // backward compatibility

  ServiceModel copyWith({
    String? title,
    List<ServiceCategory>? categories,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    String? coverImage,
    List<String>? galleryImages,
    double? rating,
  }) {
    return ServiceModel(
      id: id,
      providerId: providerId,
      title: title ?? this.title,
      categories: categories ?? this.categories,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coverImage: coverImage ?? this.coverImage,
      galleryImages: galleryImages ?? this.galleryImages,
      rating: rating ?? this.rating,
      legacyPrice: legacyPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'title': title,
      'categories': categories.map((c) => c.toMap()).toList(),
      'category': primaryCategory?.id ?? '', // legacy field
      'price': primaryPrice, // legacy field for filters
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'coverImage': coverImage,
      'galleryImages': galleryImages,
      'rating': rating,
    };
  }

  factory ServiceModel.fromMap(String id, Map<String, dynamic> map) {
    final rawCategories = map['categories'];
    List<ServiceCategory> parsedCategories = [];

    if (rawCategories is Iterable && rawCategories.isNotEmpty) {
      if (rawCategories.first is Map) {
        parsedCategories = rawCategories
            .whereType<Map>()
            .map((m) => ServiceCategory.fromMap(Map<String, dynamic>.from(m)))
            .toList();
      } else if (rawCategories.first is String) {
        parsedCategories = rawCategories
            .whereType<String>()
            .map(
              (c) => ServiceCategory(
                id: c,
                name: c,
                price: (map['price'] as num?)?.toDouble() ?? 0,
              ),
            )
            .toList();
      }
    }

    // Fallback to categoryPrices map if present
    if (parsedCategories.isEmpty && map['categoryPrices'] is Map) {
      final cp = (map['categoryPrices'] as Map).cast<String, dynamic>();
      parsedCategories = cp.entries
          .map(
            (e) => ServiceCategory(
              id: e.key,
              name: e.key,
              price: (e.value as num?)?.toDouble() ?? 0,
            ),
          )
          .toList();
    }

    // Legacy single category
    if (parsedCategories.isEmpty && map['category'] != null) {
      final cat = map['category'].toString();
      parsedCategories = [
        ServiceCategory(
          id: cat,
          name: cat,
          price: (map['price'] as num?)?.toDouble() ?? 0,
        ),
      ];
    }

    return ServiceModel(
      id: id,
      providerId: map['providerId'],
      title: map['title'],
      categories: parsedCategories,
      description: map['description'],
      location: map['location'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      coverImage: map['coverImage'],
      galleryImages: List<String>.from(map['galleryImages'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      legacyPrice: (map['price'] as num?)?.toDouble(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    providerId,
    title,
    categories,
    description,
    location,
    latitude,
    longitude,
    coverImage,
    galleryImages,
    rating,
    legacyPrice,
  ];
}
