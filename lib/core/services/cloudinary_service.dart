import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../utils/app_constants.dart';

class CloudinaryService {
  late final CloudinaryPublic _cloudinary;

  CloudinaryService() {
    final cloudName = dotenv.env[AppConstants.cloudinaryCloudNameKey] ?? '';
    final preset = dotenv.env[AppConstants.cloudinaryUploadPresetKey] ?? '';
    _cloudinary = CloudinaryPublic(cloudName, preset, cache: false);
  }

  Future<String> uploadImage(File file, {String folder = 'eventaura'}) async {
    final response = await _cloudinary.uploadFile(
      CloudinaryFile.fromFile(file.path, folder: folder),
    );
    return response.secureUrl;
  }
}
