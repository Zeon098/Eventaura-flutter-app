import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_constants.dart';

class MapboxGeocodingService {
  MapboxGeocodingService();

  String get _token => dotenv.env[AppConstants.mapboxAccessTokenKey] ?? '';

  Future<List<GeocodingResult>> forward(
    String query, {
    double? proximityLat,
    double? proximityLng,
    int limit = 5,
  }) async {
    if (_token.isEmpty || query.isEmpty) return [];
    final encoded = Uri.encodeComponent(query);
    final params = {
      'access_token': _token,
      'limit': '$limit',
      if (proximityLat != null && proximityLng != null)
        'proximity': '$proximityLng,$proximityLat',
    };
    final uri = Uri.https(
      'api.mapbox.com',
      '/geocoding/v5/mapbox.places/$encoded.json',
      params,
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return [];
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final feats = data['features'] as List<dynamic>? ?? [];
    return feats
        .whereType<Map<String, dynamic>>()
        .map(GeocodingResult.fromFeature)
        .toList();
  }

  Future<GeocodingResult?> reverse(double latitude, double longitude) async {
    if (_token.isEmpty) return null;
    final params = {'access_token': _token, 'limit': '1'};
    final uri = Uri.https(
      'api.mapbox.com',
      '/geocoding/v5/mapbox.places/$longitude,$latitude.json',
      params,
    );
    final resp = await http.get(uri);
    if (resp.statusCode != 200) return null;
    final data = json.decode(resp.body) as Map<String, dynamic>;
    final feats = data['features'] as List<dynamic>? ?? [];
    if (feats.isEmpty || feats.first is! Map<String, dynamic>) return null;
    return GeocodingResult.fromFeature(feats.first as Map<String, dynamic>);
  }
}

class GeocodingResult {
  GeocodingResult({
    required this.placeName,
    required this.latitude,
    required this.longitude,
  });

  final String placeName;
  final double latitude;
  final double longitude;

  factory GeocodingResult.fromFeature(Map<String, dynamic> feature) {
    final center = feature['center'] as List<dynamic>? ?? [];
    final lng = (center.isNotEmpty ? center[0] as num? : null)?.toDouble() ?? 0;
    final lat = (center.length > 1 ? center[1] as num? : null)?.toDouble() ?? 0;
    return GeocodingResult(
      placeName: feature['place_name']?.toString() ?? '',
      latitude: lat,
      longitude: lng,
    );
  }
}
