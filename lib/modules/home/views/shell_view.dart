import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../booking/views/booking_list_view.dart';
import '../../chat/views/chat_list_view.dart';
import '../../profile/views/profile_view.dart';
import '../../provider/views/provider_services_view.dart';
import '../controllers/shell_controller.dart';
import 'home_view.dart';

class ShellView extends GetView<ShellController> {
  const ShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final isProvider =
          controller.user.value?.role == 'provider' ||
          controller.user.value?.providerStatus == 'approved';
      final pages = <Widget>[
        const HomeView(),
        const ChatListView(),
        const BookingListView(),
        if (isProvider) const ProviderServicesView(),
        const ProfileView(),
      ];
      final labels = <String>[
        'Home',
        'Chat',
        'Bookings',
        if (isProvider) 'Services',
        'Profile',
      ];
      final icons = <IconData>[
        Icons.home_filled,
        Icons.chat_bubble_rounded,
        Icons.event_available,
        if (isProvider) Icons.store_mall_directory,
        Icons.person,
      ];
      return Scaffold(
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: IndexedStack(
              index: controller.tabIndex.value,
              children: pages,
            ),
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: controller.tabIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.primaryColor,
            unselectedItemColor: AppTheme.textSecondaryColor,
            items: List.generate(pages.length, (index) {
              return BottomNavigationBarItem(
                icon: Icon(icons[index]),
                label: labels[index],
              );
            }),
          ),
        ),
      );
    });
  }
}
