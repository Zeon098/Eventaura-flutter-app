import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_constants.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    final cloudName = dotenv.env[AppConstants.cloudinaryCloudNameKey] ?? '';
    final preset = dotenv.env[AppConstants.cloudinaryUploadPresetKey] ?? '';
    if (cloudName.isEmpty || preset.isEmpty) {
      throw StateError(
        'Cloudinary configuration missing. Ensure CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET are set in .env.',
      );
    }
    _cloudinary = CloudinaryPublic(cloudName, preset, cache: false);
  }

  Future<String> uploadImage(File file, {String folder = 'eventaura'}) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(file.path, folder: folder),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      throw Exception(
        'Cloudinary upload failed (${e.statusCode}): ${e.message}. '
        'Check cloud name, unsigned upload preset, and that unsigned uploads are enabled.',
      );
    }
  }
}
