import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/controllers/shell_controller.dart';
import '../controllers/booking_controller.dart';
import 'booking_detail_view.dart';

class BookingListView extends GetView<BookingController> {
  const BookingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<ShellController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Bookings')),
      body: StreamBuilder(
        stream: controller.watchConsumer(shell.user.value?.id ?? ''),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final bookings = snapshot.data!;
          if (bookings.isEmpty)
            return const Center(child: Text('No bookings yet'));
          return ListView.separated(
            itemCount: bookings.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, index) {
              final booking = bookings[index];
              return ListTile(
                title: Text('Booking ${booking.id.substring(0, 6)}'),
                subtitle: Text('Status: ${booking.status}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Get.to(() => BookingDetailView(booking: booking)),
              );
            },
          );
        },
      ),
    );
  }
}
