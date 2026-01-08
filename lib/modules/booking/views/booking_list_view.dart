import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../home/controllers/shell_controller.dart';
import '../components/booking_list_tab.dart';
import '../components/booking_list_tab_combined.dart';
import '../controllers/booking_controller.dart';

class BookingListView extends GetView<BookingController> {
  const BookingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    final user = shell.user.value;
    final userId = user?.id ?? '';
    final isProvider = user?.role == 'provider' || user?.isProvider == true;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Text(
            'My Bookings',
            style: TextStyle(
              color: AppTheme.textPrimaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondaryColor,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '📋 Requests'),
                  Tab(text: '🚀 Upcoming'),
                  Tab(text: '📜 History'),
                ],
              ),
            ),
          ),
        ),
        body: isProvider
            ? TabBarView(
                children: [
                  BookingListTabCombined(
                    stream: controller.combinedRequests(userId),
                    userId: userId,
                  ),
                  BookingListTabCombined(
                    stream: controller.combinedUpcoming(userId),
                    userId: userId,
                  ),
                  BookingListTabCombined(
                    stream: controller.combinedHistory(userId),
                    userId: userId,
                  ),
                ],
              )
            : TabBarView(
                children: [
                  BookingListTab(
                    stream: controller.consumerRequests(userId),
                    isProvider: false,
                  ),
                  BookingListTab(
                    stream: controller.consumerUpcoming(userId),
                    isProvider: false,
                  ),
                  BookingListTab(
                    stream: controller.consumerHistory(userId),
                    isProvider: false,
                  ),
                ],
              ),
      ),
    );
  }
}
