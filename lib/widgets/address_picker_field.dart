import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../modules/location/address_picker_map_view.dart';

class AddressPickerField extends StatelessWidget {
  const AddressPickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.initialLat,
    this.initialLng,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final void Function(String address, double lat, double lng) onChanged;
  final double? initialLat;
  final double? initialLng;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(
          () => const AddressPickerMapView(),
          arguments: {
            'address': controller.text,
            'lat': initialLat,
            'lng': initialLng,
          },
        );
        if (result is Map<String, dynamic>) {
          final addr = result['address']?.toString() ?? '';
          final lat = (result['latitude'] as num?)?.toDouble();
          final lng = (result['longitude'] as num?)?.toDouble();
          if (addr.isNotEmpty && lat != null && lng != null) {
            controller.text = addr;
            onChanged(addr, lat, lng);
          }
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            suffixIcon: const Icon(Icons.map_outlined),
          ),
          validator: (v) =>
              v == null || v.isEmpty ? 'Please pick a location' : null,
        ),
      ),
    );
  }
}
