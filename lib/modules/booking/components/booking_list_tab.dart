import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import 'booking_card.dart';
import 'booking_dialog.dart';

class BookingListTab extends StatelessWidget {
  const BookingListTab({
    super.key,
    required this.stream,
    required this.isProvider,
  });

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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No bookings yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (_, index) {
            final booking = bookings[index];
            return BookingCard(
              booking: booking,
              isProvider: isProvider,
              onTap: () => _showBookingDialog(context, booking),
            );
          },
        );
      },
    );
  }

  void _showBookingDialog(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (_) => BookingDialog(booking: booking, isProvider: isProvider),
    );
  }
}
