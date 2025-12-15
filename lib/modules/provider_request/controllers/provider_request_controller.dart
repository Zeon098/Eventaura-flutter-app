import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/stores/user_store.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/provider_request_model.dart';
import '../../../data/repositories/provider_request_repository.dart';
import '../../../data/repositories/user_repository.dart';

class ProviderRequestController extends GetxController {
  ProviderRequestController({
    required this.providerRequestRepository,
    required this.cloudinaryService,
    required this.userStore,
    required this.userRepository,
  });

  final ProviderRequestRepository providerRequestRepository;
  final CloudinaryService cloudinaryService;
  final UserStore userStore;
  final UserRepository userRepository;

  final request = Rxn<ProviderRequest>();
  final isSubmitting = false.obs;
  final picker = ImagePicker();
  File? cnicFront;
  File? cnicBack;

  @override
  void onInit() {
    super.onInit();
    final userId = userStore.value?.id;
    if (userId != null && userId.isNotEmpty) {
      providerRequestRepository.watchForUser(userId).listen((req) {
        request.value = req;
        _syncUserProviderState(req);
        update();
      });
    }
  }

  bool get canSubmit {
    final status = request.value?.status;
    if (status == 'pending' || status == 'approved') return false;
    return true;
  }

  String get statusLabel => request.value?.status ?? 'none';

  Future<void> pickFront() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) cnicFront = File(picked.path);
    update();
  }

  Future<void> pickBack() async {
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) cnicBack = File(picked.path);
    update();
  }

  Future<void> submit({
    required String businessName,
    required String description,
  }) async {
    final userId = userStore.value?.id;
    if (userId == null || userId.isEmpty) {
      SnackbarUtils.error('Session', 'You need to login again');
      return;
    }
    if (!canSubmit) {
      SnackbarUtils.error(
        'Already submitted',
        'Your request is already ${request.value?.status ?? 'pending'}',
      );
      return;
    }
    try {
      isSubmitting.value = true;
      final existing = request.value;
      final frontUrl = cnicFront != null
          ? await cloudinaryService.uploadImage(cnicFront!, folder: 'cnic')
          : existing?.cnicFrontUrl;
      final backUrl = cnicBack != null
          ? await cloudinaryService.uploadImage(cnicBack!, folder: 'cnic')
          : existing?.cnicBackUrl;
      if (frontUrl == null || backUrl == null) {
        SnackbarUtils.error('Missing files', 'Upload both CNIC images');
        return;
      }
      final now = DateTime.now();
      final payload = ProviderRequest(
        id: userId,
        userId: userId,
        businessName: businessName,
        description: description,
        cnicFrontUrl: frontUrl,
        cnicBackUrl: backUrl,
        status: 'pending',
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      );
      await providerRequestRepository.submit(payload);
      await userRepository.patchUser(userId, {
        'providerStatus': 'pending',
        'isProvider': false,
        'role': 'user',
      });
      request.value = payload;
      SnackbarUtils.success(
        'Submitted',
        'We will review your request within 24-48 hours.',
      );
      update();
    } catch (e) {
      debugPrint('Provider request submit error: $e');
      SnackbarUtils.error('Provider request', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> _syncUserProviderState(ProviderRequest? req) async {
    final user = userStore.value;
    if (user == null || req == null) return;
    final userId = user.id;
    String? targetRole;
    bool? targetProviderFlag;
    switch (req.status) {
      case 'approved':
        targetRole = 'provider';
        targetProviderFlag = true;
        break;
      case 'rejected':
      case 'pending':
        targetRole = 'user';
        targetProviderFlag = false;
        break;
      default:
        return;
    }
    if (user.role == targetRole &&
        user.providerStatus == req.status &&
        user.isProvider == targetProviderFlag) {
      return;
    }
    await userRepository.patchUser(userId, {
      'providerStatus': req.status,
      'isProvider': targetProviderFlag,
      'role': targetRole,
    });
  }
}
