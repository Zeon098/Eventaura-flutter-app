import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? fcmToken;
  final bool isProvider;
  final String providerStatus; // pending | approved | rejected | none

  const AppUser({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.city,
    this.latitude,
    this.longitude,
    this.fcmToken,
    this.isProvider = false,
    this.providerStatus = 'none',
  });

  factory AppUser.empty() => const AppUser(id: '', email: '');

  AppUser copyWith({
    String? displayName,
    String? photoUrl,
    String? city,
    double? latitude,
    double? longitude,
    String? fcmToken,
    bool? isProvider,
    String? providerStatus,
  }) {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fcmToken: fcmToken ?? this.fcmToken,
      isProvider: isProvider ?? this.isProvider,
      providerStatus: providerStatus ?? this.providerStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'fcmToken': fcmToken,
      'isProvider': isProvider,
      'providerStatus': providerStatus,
    };
  }

  factory AppUser.fromMap(String id, Map<String, dynamic> map) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      city: map['city'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      fcmToken: map['fcmToken'],
      isProvider: map['isProvider'] ?? false,
      providerStatus: map['providerStatus'] ?? 'none',
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    city,
    latitude,
    longitude,
    fcmToken,
    isProvider,
    providerStatus,
  ];
}
