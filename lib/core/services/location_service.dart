import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';

/// Provides location permission handling, geolocation, and reverse geocoding.
class LocationService {
  /// Ensure location permission is granted; returns true if granted.
  Future<bool> ensurePermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  /// Get current position with best accuracy.
  Future<Position> getCurrentPosition() async {
    final permitted = await ensurePermission();
    if (!permitted) {
      throw PermissionDeniedException('Location permission denied');
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  Future<(double lat, double lng)?> currentLatLngOrNull() async {
    try {
      final pos = await getCurrentPosition();
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  /// Reverse geocode city/locality from coordinates.
  Future<String?> reverseGeocodeCity(double latitude, double longitude) async {
    final placemarks = await geo.placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isEmpty) return null;
    final place = placemarks.first;
    return place.locality?.isNotEmpty == true
        ? place.locality
        : place.subAdministrativeArea;
  }
}

class PermissionDeniedException implements Exception {
  PermissionDeniedException(this.message);
  final String message;

  @override
  String toString() => message;
}
