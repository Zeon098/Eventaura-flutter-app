import 'package:get/get.dart';
import '../../data/models/user_model.dart';

/// Central reactive store for the authenticated user profile.
class UserStore extends GetxService {
  final Rxn<AppUser> user = Rxn<AppUser>();

  AppUser? get value => user.value;

  void setUser(AppUser? profile) => user.value = profile;

  void clear() => user.value = null;
}
