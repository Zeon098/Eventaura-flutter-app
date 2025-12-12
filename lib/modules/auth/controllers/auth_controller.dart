import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/user_repository.dart';

class AuthController extends GetxController {
  AuthController({required this.authRepository, required this.userRepository});

  final AuthRepository authRepository;
  final UserRepository userRepository;

  final isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      await authRepository.signIn(email: email, password: password);
      SnackbarUtils.success('Welcome back', 'Signed in successfully');
      Get.offAllNamed('/shell');
    } catch (e) {
      debugPrint('Login error: $e');
      SnackbarUtils.error('Login failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      final user = await authRepository.signUp(
        email: email,
        password: password,
        name: name,
      );
      await userRepository.upsertUser(user);
      SnackbarUtils.success('Account created', 'Welcome to Eventaura');
      Get.offAllNamed('/shell');
    } catch (e) {
      SnackbarUtils.error('Register failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await authRepository.signOut();
    Get.offAllNamed('/login');
  }
}
