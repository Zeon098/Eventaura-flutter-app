import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_model.dart';
import '../../services/views/service_detail_view.dart';

class VerticalVenueCard extends StatelessWidget {
  final ServiceModel service;

  const VerticalVenueCard({super.key, required this.service});

  String _getPricingTypeLabel(String pricingType) {
    switch (pricingType) {
      case 'per_head':
        return 'per person';
      case 'per_100_persons':
        return 'per 100 persons';
      case 'base':
      default:
        return 'base price';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const ServiceDetailView(), arguments: service),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: service.coverImage.isNotEmpty
                    ? Image.network(
                        service.coverImage,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.dividerColor,
                          child: Icon(
                            Icons.business,
                            size: 48,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.dividerColor,
                        child: Icon(
                          Icons.business,
                          size: 48,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
              ),
            ),

            // Content section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          service.location,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryColor,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Categories and Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Categories
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: service.categories.take(2).map((cat) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cat.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      // Price
                      if (service.categories.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor,
                                    AppTheme.secondaryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PKR ${service.categories.first.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            if (service.categories.first.pricingType != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _getPricingTypeLabel(
                                    service.categories.first.pricingType!,
                                  ),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.textSecondaryColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
