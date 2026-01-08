import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/utils/app_constants.dart';
import '../../../data/models/service_model.dart';
import '../../services/views/service_detail_view.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late final List<ServiceModel> _services;
  double? _centerLat;
  double? _centerLng;
  MapboxMap? _mapboxMap;
  PointAnnotationManager? _pointManager;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _services = ((args['services'] as List<ServiceModel>?) ?? [])
        .where((s) => s.latitude != null && s.longitude != null)
        .toList();
    final center = args['center'];
    if (center is Map) {
      _centerLat = (center['lat'] as num?)?.toDouble();
      _centerLng = (center['lng'] as num?)?.toDouble();
    }
  }

  @override
  void dispose() {
    _pointManager?.deleteAll();
    super.dispose();
  }

  CameraOptions _initialCamera() {
    if (_centerLat != null && _centerLng != null) {
      return CameraOptions(
        center: Point(coordinates: Position(_centerLng!, _centerLat!)),
        zoom: 12,
      );
    }
    if (_services.isNotEmpty &&
        _services.first.latitude != null &&
        _services.first.longitude != null) {
      return CameraOptions(
        center: Point(
          coordinates: Position(
            _services.first.longitude!,
            _services.first.latitude!,
          ),
        ),
        zoom: 12,
      );
    }
    return CameraOptions(
      center: Point(coordinates: Position(0, 0)),
      zoom: 2,
    );
  }

  Future<void> _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    final token = dotenv.env[AppConstants.mapboxAccessTokenKey] ?? '';
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mapbox access token missing in .env')),
      );
      return;
    }

    await _mapboxMap!.loadStyleURI(AppConstants.mapboxStyleLight);
    _pointManager = await _mapboxMap!.annotations.createPointAnnotationManager();
    await _addServiceAnnotations();
  }

  Future<void> _addServiceAnnotations() async {
    if (_pointManager == null) return;
    await _pointManager!.deleteAll();

    // Service markers
    final serviceOptions = _services.map((s) {
      return PointAnnotationOptions(
        geometry: Point(
          coordinates: Position(s.longitude!, s.latitude!),
        ),
        iconImage: 'marker-15',
        iconSize: 1.5,
        textField: s.title,
        textOffset: const [0, 1.6],
      );
    }).toList();

    final created = await _pointManager!.createMulti(serviceOptions);

    // Current location marker (center)
    if (_centerLat != null && _centerLng != null) {
      await _pointManager!.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(_centerLng!, _centerLat!),
          ),
          iconImage: 'harbor-15',
          iconColor: 0xFF1E88E5,
          iconSize: 1.6,
          textField: 'You',
          textOffset: const [0, 1.6],
        ),
      );
    }

    final idToService = <Object, ServiceModel>{};
    for (var i = 0; i < created.length; i++) {
      final ann = created[i];
      if (ann != null) {
        idToService[ann.id] = _services[i];
      }
    }

    _pointManager!.addOnPointAnnotationClickListener(
      _PointTapListener((annotation) {
        final svc = idToService[annotation.id];
        if (svc != null) {
          _showServiceSheet(svc);
        }
      }),
    );
  }

  void _showServiceSheet(ServiceModel service) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  service.primaryCategoryName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              service.location,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.to(() => const ServiceDetailView(), arguments: service);
                },
                child: const Text('View details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final token = dotenv.env[AppConstants.mapboxAccessTokenKey] ?? '';
    if (token.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Mapbox token not configured.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Services Map')),
      body: MapWidget(
        cameraOptions: _initialCamera(),
        styleUri: AppConstants.mapboxStyleLight,
        onMapCreated: _onMapCreated,
      ),
    );
  }
}

class _PointTapListener extends OnPointAnnotationClickListener {
  _PointTapListener(this.onTap);
  final void Function(PointAnnotation) onTap;

  @override
  bool onPointAnnotationClick(PointAnnotation annotation) {
    onTap(annotation);
    return true;
  }
}
