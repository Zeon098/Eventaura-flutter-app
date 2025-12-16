import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../data/models/service_model.dart';
import '../../services/views/service_detail_view.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final services = (args?['services'] as List<ServiceModel>?) ?? [];
    final center = args?['center'] as LatLng?;

    final markers = services
        .where((s) => s.latitude != null && s.longitude != null)
        .map(
          (s) => Marker(
            markerId: MarkerId(s.id),
            position: LatLng(s.latitude!, s.longitude!),
            infoWindow: InfoWindow(
              title: s.title,
              snippet: s.location,
              onTap: () {
                Get.to(() => const ServiceDetailView(), arguments: s);
              },
            ),
          ),
        )
        .toSet();

    final initial = center != null
        ? CameraPosition(target: center, zoom: 12)
        : (markers.isNotEmpty
              ? CameraPosition(target: markers.first.position, zoom: 12)
              : const CameraPosition(target: LatLng(0, 0), zoom: 2));

    return Scaffold(
      appBar: AppBar(title: const Text('Services Map')),
      body: GoogleMap(
        initialCameraPosition: initial,
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
