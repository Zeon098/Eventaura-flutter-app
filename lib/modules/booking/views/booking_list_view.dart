import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/booking_model.dart';
import '../../home/controllers/shell_controller.dart';
import '../controllers/booking_controller.dart';
import 'booking_detail_view.dart';

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
        appBar: AppBar(
          title: const Text('Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Requests'),
              Tab(text: 'Upcoming'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _BookingListTab(
              stream: isProvider
                  ? controller.providerRequests(userId)
                  : controller.consumerRequests(userId),
              isProvider: isProvider,
            ),
            _BookingListTab(
              stream: isProvider
                  ? controller.providerUpcoming(userId)
                  : controller.consumerUpcoming(userId),
              isProvider: isProvider,
            ),
            _BookingListTab(
              stream: isProvider
                  ? controller.providerHistory(userId)
                  : controller.consumerHistory(userId),
              isProvider: isProvider,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingListTab extends StatelessWidget {
  const _BookingListTab({required this.stream, required this.isProvider});

  final Stream<List<BookingModel>> stream;
  final bool isProvider;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final bookings = snapshot.data!;
        if (bookings.isEmpty) {
          return const Center(child: Text('No bookings'));
        }
        return ListView.separated(
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final booking = bookings[index];
            return ListTile(
              title: Text(_titleText(booking)),
              subtitle: Text(_subtitleText(booking, isProvider)),
              trailing: _StatusChip(status: booking.status),
              onTap: () => Get.to(() => BookingDetailView(booking: booking)),
            );
          },
        );
      },
    );
  }

  String _titleText(BookingModel booking) {
    final date = DateFormat('EEE, MMM d').format(booking.startTime);
    final range = _timeRange(booking);
    return '$date · $range';
  }

  String _subtitleText(BookingModel booking, bool isProvider) {
    final counterpart = isProvider
        ? 'Consumer: ${booking.consumerId}'
        : 'Provider: ${booking.providerId}';
    return '$counterpart\nStatus: ${booking.status}';
  }

  String _timeRange(BookingModel booking) {
    final fmt = DateFormat('h:mm a');
    return '${fmt.format(booking.startTime)} - ${fmt.format(booking.endTime)}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  Color _colorForStatus(BuildContext context) {
    switch (status) {
      case BookingModel.accepted:
        return Colors.green.shade100;
      case BookingModel.rejected:
      case BookingModel.cancelled:
        return Colors.red.shade100;
      case BookingModel.completed:
        return Colors.blue.shade100;
      default:
        return Theme.of(context).colorScheme.secondaryContainer;
    }
  }

  Color _textColor(BuildContext context) {
    switch (status) {
      case BookingModel.accepted:
        return Colors.green.shade800;
      case BookingModel.rejected:
      case BookingModel.cancelled:
        return Colors.red.shade800;
      case BookingModel.completed:
        return Colors.blue.shade800;
      default:
        return Theme.of(context).colorScheme.onSecondaryContainer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status),
      backgroundColor: _colorForStatus(context),
      labelStyle: TextStyle(
        color: _textColor(context),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
