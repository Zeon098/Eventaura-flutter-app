import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../controllers/service_controller.dart';

class MediaSection extends StatelessWidget {
  final String? coverImageUrl;
  final List<String> galleryImageUrls;

  const MediaSection({
    super.key,
    this.coverImageUrl,
    this.galleryImageUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(
      builder: (controller) {
        final hasCoverImage =
            controller.cover != null || (coverImageUrl?.isNotEmpty ?? false);
        final hasGalleryImages =
            controller.gallery.isNotEmpty || galleryImageUrls.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Buttons Row
            Row(
              children: [
                Expanded(
                  child: _MediaButton(
                    icon: Icons.image,
                    label: 'Cover Image',
                    onTap: controller.pickCover,
                    hasMedia: hasCoverImage,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MediaButton(
                    icon: Icons.collections,
                    label: 'Gallery',
                    onTap: controller.pickGallery,
                    hasMedia: hasGalleryImages,
                  ),
                ),
              ],
            ),

            // Media Preview Section
            if (hasCoverImage || hasGalleryImages) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📸 Image Preview',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Cover Image Preview
                    if (hasCoverImage) ...[
                      Text(
                        'Cover Image',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: controller.cover != null
                                ? Image.file(
                                    File(controller.cover!.path),
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    coverImageUrl!,
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: double.infinity,
                                      height: 180,
                                      color: AppTheme.surfaceColor,
                                      child: Icon(
                                        Icons.broken_image,
                                        color: AppTheme.textSecondaryColor,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                padding: const EdgeInsets.all(4),
                                constraints: const BoxConstraints(),
                                onPressed: () {
                                  controller.cover = null;
                                  controller.update();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Gallery Preview
                    if (hasGalleryImages) ...[
                      Text(
                        'Gallery Images (${controller.gallery.length + galleryImageUrls.length})',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              controller.gallery.length +
                              galleryImageUrls.length,
                          itemBuilder: (context, index) {
                            final isNewImage =
                                index < controller.gallery.length;

                            return Container(
                              margin: const EdgeInsets.only(right: 12),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: isNewImage
                                        ? Image.file(
                                            File(
                                              controller.gallery[index].path,
                                            ),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            galleryImageUrls[index -
                                                controller.gallery.length],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                                  width: 100,
                                                  height: 100,
                                                  color: AppTheme.surfaceColor,
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: AppTheme
                                                        .textSecondaryColor,
                                                  ),
                                                ),
                                          ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          if (isNewImage) {
                                            controller.gallery.removeAt(index);
                                            controller.update();
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

// Simple stateless button widget - no reactivity needed
class _MediaButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool hasMedia;

  const _MediaButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.hasMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: hasMedia
            ? LinearGradient(
                colors: [AppTheme.successColor.withOpacity(0.1), Colors.white],
              )
            : LinearGradient(colors: [Colors.white, AppTheme.surfaceColor]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasMedia
              ? AppTheme.successColor.withOpacity(0.5)
              : AppTheme.primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasMedia ? Icons.check_circle : icon,
                color: hasMedia ? AppTheme.successColor : AppTheme.primaryColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: hasMedia
                      ? AppTheme.successColor
                      : AppTheme.textPrimaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasMedia)
                Text(
                  'Added ✓',
                  style: TextStyle(color: AppTheme.successColor, fontSize: 11),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
