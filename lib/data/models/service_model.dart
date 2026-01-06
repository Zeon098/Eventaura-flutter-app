import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String providerId;
  final String title;
  final List<String> categories;
  final double price;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final String coverImage;
  final List<String> galleryImages;
  final double rating;

  const ServiceModel({
    required this.id,
    required this.providerId,
    required this.title,
    required this.categories,
    required this.price,
    required this.description,
    required this.location,
    required this.coverImage,
    required this.galleryImages,
    this.latitude,
    this.longitude,
    this.rating = 0,
  });

  String get primaryCategory => categories.isNotEmpty ? categories.first : '';
  String get category => primaryCategory; // Backward compatibility

  ServiceModel copyWith({
    String? title,
    List<String>? categories,
    double? price,
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
      price: price ?? this.price,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coverImage: coverImage ?? this.coverImage,
      galleryImages: galleryImages ?? this.galleryImages,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'title': title,
      'categories': categories,
      'category': primaryCategory, // keep legacy field
      'price': price,
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
    final mappedCategories = map['categories'];
    final categoryList = mappedCategories is Iterable
        ? List<String>.from(mappedCategories)
        : map['category'] != null
        ? [map['category'].toString()]
        : <String>[];

    return ServiceModel(
      id: id,
      providerId: map['providerId'],
      title: map['title'],
      categories: categoryList,
      price: (map['price'] as num?)?.toDouble() ?? 0,
      description: map['description'],
      location: map['location'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      coverImage: map['coverImage'],
      galleryImages: List<String>.from(map['galleryImages'] ?? []),
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    id,
    providerId,
    title,
    categories,
    price,
    description,
    location,
    latitude,
    longitude,
    coverImage,
    galleryImages,
    rating,
  ];
}
