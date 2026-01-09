import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../core/services/location_service.dart';
import '../../core/services/mapbox_geocoding_service.dart';
import '../../core/utils/app_constants.dart';

class AddressPickerMapView extends StatefulWidget {
  const AddressPickerMapView({super.key});

  @override
  State<AddressPickerMapView> createState() => _AddressPickerMapViewState();
}

class _AddressPickerMapViewState extends State<AddressPickerMapView> {
  final _geocoding = MapboxGeocodingService();
  final _searchController = TextEditingController();
  Timer? _debounce;
  List<GeocodingResult> _results = [];
  MapboxMap? _map;
  double? _lat;
  double? _lng;
  bool _isLocating = false;
  String _address = '';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    _address = args?['address']?.toString() ?? '';
    _lat = (args?['lat'] as num?)?.toDouble();
    _lng = (args?['lng'] as num?)?.toDouble();
    if (_address.isNotEmpty) _searchController.text = _address;
    _initPosition();
  }

  Future<void> _initPosition() async {
    final loc = Get.find<LocationService>();
    try {
      final position = await loc.getCurrentPosition();
      _lat ??= position.latitude;
      _lng ??= position.longitude;
      setState(() {});
    } catch (_) {
      _lat ??= 0;
      _lng ??= 0;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _moveTo(double lat, double lng) {
    _lat = lat;
    _lng = lng;
    _map?.flyTo(
      CameraOptions(center: Point(coordinates: Position(lng, lat)), zoom: 15),
      MapAnimationOptions(duration: 800, startDelay: 0),
    );
  }

  Future<void> _onSearchChanged(String value) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (value.isEmpty) {
        setState(() => _results = []);
        return;
      }
      final results = await _geocoding.forward(
        value,
        proximityLat: _lat,
        proximityLng: _lng,
      );
      setState(() => _results = results);
    });
  }

  Future<void> _useCurrentCenter() async {
    final cameraState = await _map?.getCameraState();
    final center = cameraState?.center;
    if (center is Point) {
      final coords = center.coordinates;
      _lat = coords.lat.toDouble();
      _lng = coords.lng.toDouble();
    }
    if (_lat == null || _lng == null) return;
    final rev = await _geocoding.reverse(_lat!, _lng!);
    final addr = rev?.placeName ?? _address;
    Get.back(result: {'address': addr, 'latitude': _lat!, 'longitude': _lng!});
  }

  Future<void> _centerOnUser() async {
    if (_isLocating) return;
    setState(() => _isLocating = true);
    final loc = Get.find<LocationService>();
    final pos = await loc.currentLatLngOrNull();
    if (pos != null) {
      _moveTo(pos.$1, pos.$2);
    } else {
      if (mounted) {
        Get.snackbar('Location', 'Unable to fetch current location');
      }
    }
    if (mounted) setState(() => _isLocating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _useCurrentCenter,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search places',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_results.isNotEmpty)
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final r = _results[i];
                  return ListTile(
                    title: Text(
                      r.placeName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      setState(() {
                        _address = r.placeName;
                      });
                      _moveTo(r.latitude, r.longitude);
                      _results = [];
                    },
                  );
                },
              ),
            ),
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_lat != null && _lng != null)
                  MapWidget(
                    key: ValueKey('map_${_lat}_$_lng'),
                    cameraOptions: CameraOptions(
                      center: Point(coordinates: Position(_lng!, _lat!)),
                      zoom: 15,
                    ),
                    styleUri: AppConstants.mapboxStyleLight,
                    onMapCreated: (map) {
                      _map = map;
                      map.setCamera(
                        CameraOptions(
                          center: Point(coordinates: Position(_lng!, _lat!)),
                          zoom: 15,
                        ),
                      );
                    },
                  )
                else
                  const Center(child: CircularProgressIndicator()),
                const Icon(
                  Icons.location_pin,
                  size: 42,
                  color: Colors.redAccent,
                ),
                Positioned(
                  bottom: 84,
                  right: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'my_location',
                    onPressed: _isLocating ? null : _centerOnUser,
                    child: _isLocating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: ElevatedButton(
                    onPressed: _useCurrentCenter,
                    child: const Text('Use this location'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
