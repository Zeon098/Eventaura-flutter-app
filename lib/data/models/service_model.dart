import 'package:equatable/equatable.dart';

class ServiceModel extends Equatable {
  final String id;
  final String providerId;
  final String title;
  final String category;
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
    required this.category,
    required this.price,
    required this.description,
    required this.location,
    required this.coverImage,
    required this.galleryImages,
    this.latitude,
    this.longitude,
    this.rating = 0,
  });

  ServiceModel copyWith({
    String? title,
    String? category,
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
      category: category ?? this.category,
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
      'category': category,
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
    return ServiceModel(
      id: id,
      providerId: map['providerId'],
      title: map['title'],
      category: map['category'],
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
    category,
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
