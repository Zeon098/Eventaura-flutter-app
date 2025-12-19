import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_model.dart';

class ServiceDescription extends StatelessWidget {
  final ServiceModel service;

  const ServiceDescription({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: AppTheme.primaryColor, size: 22),
            const SizedBox(width: 8),
            Text(
              'About Service',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          service.description,
          style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: AppTheme.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}
