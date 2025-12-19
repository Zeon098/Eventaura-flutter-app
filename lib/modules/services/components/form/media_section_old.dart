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
    final controller = Get.find<ServiceController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MediaButton(
                controller: controller,
                icon: Icons.image,
                label: 'Cover Image',
                onTap: controller.pickCover,
                isCover: true,
                coverImageUrl: coverImageUrl,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MediaButton(
                controller: controller,
                icon: Icons.collections,
                label: 'Gallery',
                onTap: controller.pickGallery,
                isCover: false,
                galleryImageUrls: galleryImageUrls,
              ),
            ),
          ],
        ),
        _MediaPreviewWrapper(
          controller: controller,
          coverImageUrl: coverImageUrl,
          galleryImageUrls: galleryImageUrls,
        ),
      ],
    );
  }
}

class _MediaButton extends StatelessWidget {
  final ServiceController controller;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isCover;
  final String? coverImageUrl;
  final List<String> galleryImageUrls;

  const _MediaButton({
    required this.controller,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isCover,
    this.coverImageUrl,
    this.galleryImageUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Access reactive variables directly inside Obx
      final media = isCover
          ? (controller.cover != null || (coverImageUrl?.isNotEmpty ?? false))
          : (controller.gallery.isNotEmpty || galleryImageUrls.isNotEmpty);
      
      return Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: media
              ? LinearGradient(
                  colors: [
                    AppTheme.successColor.withOpacity(0.1),
                    Colors.white
                  ],
                )
              : LinearGradient(colors: [Colors.white, AppTheme.surfaceColor]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: media
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
                  media ? Icons.check_circle : icon,
                  color: media ? AppTheme.successColor : AppTheme.primaryColor,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: media
                        ? AppTheme.successColor
                        : AppTheme.textPrimaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (media)
                  Text(
                    'Added ✓',
                    style:
                        TextStyle(color: AppTheme.successColor, fontSize: 11),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _MediaPreviewWrapper extends StatelessWidget {
  final ServiceController controller;
  final String? coverImageUrl;
  final List<String> galleryImageUrls;

  const _MediaPreviewWrapper({
    required this.controller,
    this.coverImageUrl,
    this.galleryImageUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Access reactive variables directly inside Obx
      final hasCover =
          controller.cover != null || (coverImageUrl?.isNotEmpty ?? false);
      final hasGallery =
          controller.gallery.isNotEmpty || galleryImageUrls.isNotEmpty;

      if (!hasCover && !hasGallery) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                _CoverImagePreview(
                  controller: controller,
                  coverImageUrl: coverImageUrl,
                ),
                _GalleryPreview(
                  controller: controller,
                  galleryImageUrls: galleryImageUrls,
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _CoverImagePreview extends StatelessWidget {
  final ServiceController controller;
  final String? coverImageUrl;

  const _CoverImagePreview({
    required this.controller,
    this.coverImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Access reactive variables directly inside Obx
      if (controller.cover == null && (coverImageUrl?.isEmpty ?? true)) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                        errorBuilder: (context, error, stack) {
                          return Container(
                            width: double.infinity,
                            height: 180,
                            color: AppTheme.surfaceColor,
                            child: Icon(
                              Icons.broken_image,
                              color: AppTheme.textSecondaryColor,
                              size: 48,
                            ),
                          );
                        },
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
                    icon: Icon(Icons.close, color: Colors.white, size: 20),
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      controller.cover = null;
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      );
    });
  }
}

class _GalleryPreview extends StatelessWidget {
  final ServiceController controller;
  final List<String> galleryImageUrls;

  const _GalleryPreview({
    required this.controller,
    this.galleryImageUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Access reactive variables directly inside Obx
      if (controller.gallery.isEmpty && galleryImageUrls.isEmpty) {
        return const SizedBox.shrink();
      }

      final totalCount = controller.gallery.length + galleryImageUrls.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery Images ($totalCount)',
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
              itemCount: totalCount,
              itemBuilder: (context, index) {
                final isNewImage = index < controller.gallery.length;

                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isNewImage
                            ? Image.file(
                                File(controller.gallery[index].path),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                galleryImageUrls[
                                    index - controller.gallery.length],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: AppTheme.surfaceColor,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: AppTheme.textSecondaryColor,
                                    ),
                                  );
                                },
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
                            icon: Icon(Icons.close,
                                color: Colors.white, size: 16),
                            padding: const EdgeInsets.all(2),
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              if (isNewImage) {
                                controller.gallery.removeAt(index);
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
      );
    });
  }
}
