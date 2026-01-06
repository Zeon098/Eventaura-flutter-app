import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/home/bindings/shell_binding.dart';
import '../modules/home/views/shell_view.dart';
import '../modules/services/bindings/service_binding.dart';
import '../modules/services/views/service_form_view.dart';
import '../modules/services/views/service_detail_view.dart';
import '../modules/booking/bindings/booking_binding.dart';
import '../modules/booking/views/booking_detail_view.dart';
import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_room_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/provider_request/bindings/provider_request_binding.dart';
import '../modules/provider_request/views/provider_request_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = <GetPage<dynamic>>[
    GetPage(
      name: Routes.splash,
      page: () => const ShellView(),
      binding: ShellBinding(),
      participatesInRootNavigator: true,
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.shell,
      page: () => const ShellView(),
      binding: ShellBinding(),
    ),
    GetPage(
      name: Routes.serviceForm,
      page: () => const ServiceFormView(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: Routes.serviceDetail,
      page: () => const ServiceDetailView(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: Routes.bookingDetail,
      page: () => BookingDetailView(booking: Get.arguments),
      binding: BookingBinding(),
    ),
    GetPage(
      name: Routes.chatRoom,
      page: () => ChatRoomView(roomId: Get.arguments),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.providerRequest,
      page: () => const ProviderRequestView(),
      binding: ProviderRequestBinding(),
    ),
  ];
}
