import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/booking_model.dart';
import '../controllers/booking_controller.dart';

class BookingDetailView extends GetView<BookingController> {
  const BookingDetailView({super.key, required this.booking});

  final BookingModel booking;

  @override
  Widget build(BuildContext context) {
    final user = controller.userStore.value;
    final isProvider = user?.role == 'provider' || user?.isProvider == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Booking detail')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Booking ID', booking.id),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Status'),
                Chip(label: Text(booking.status)),
              ],
            ),
            _row('Service', booking.serviceId),
            _row('Provider', booking.providerId),
            _row('Consumer', booking.consumerId),
            _row(
              'Date',
              DateFormat('EEE, MMM d, yyyy').format(booking.startTime),
            ),
            _row(
              'Time',
              '${DateFormat('h:mm a').format(booking.startTime)} - ${DateFormat('h:mm a').format(booking.endTime)}',
            ),
            const Spacer(),
            if (isProvider)
              _ActionButtons(booking: booking, controller: controller),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ActionButtons extends GetView {
  const _ActionButtons({required this.booking, required this.controller});

  final BookingModel booking;
  final BookingController controller;

  @override
  Widget build(BuildContext context) {
    final actions = <Widget>[];

    if (booking.isPending) {
      actions.addAll([
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            onPressed: () =>
                controller.updateStatus(booking.id, BookingModel.accepted),
            child: const Text('Accept'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            onPressed: () =>
                controller.updateStatus(booking.id, BookingModel.rejected),
            child: const Text('Reject'),
          ),
        ),
      ]);
    } else if (booking.isAccepted) {
      actions.add(
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
            onPressed: () =>
                controller.updateStatus(booking.id, BookingModel.completed),
            child: const Text('Mark Completed'),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(children: actions);
  }
}
