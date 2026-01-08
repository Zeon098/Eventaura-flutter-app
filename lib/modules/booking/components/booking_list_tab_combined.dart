import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/booking_controller.dart';
import 'booking_card.dart';
import 'booking_dialog.dart';

class BookingListTabCombined extends StatelessWidget {
  const BookingListTabCombined({
    super.key,
    required this.stream,
    required this.userId,
  });

  final Stream<List<BookingWithDirection>> stream;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingWithDirection>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final bookingsWithDirection = snapshot.data!;
        if (bookingsWithDirection.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.event_busy,
                  size: 80,
                  color: AppTheme.textSecondaryColor.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No bookings yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookingsWithDirection.length,
          itemBuilder: (_, index) {
            final item = bookingsWithDirection[index];
            final booking = item.booking;
            final isIncoming = item.direction == BookingDirection.incoming;
            // Determine if current user is provider for this specific booking
            final isProviderForThisBooking = booking.providerId == userId;

            return BookingCard(
              booking: booking,
              isProvider: isProviderForThisBooking,
              showDirection: true,
              isIncoming: isIncoming,
              onTap: () => _showBookingDialog(
                context,
                booking,
                isProviderForThisBooking,
              ),
            );
          },
        );
      },
    );
  }

  void _showBookingDialog(
    BuildContext context,
    dynamic booking,
    bool isProvider,
  ) {
    showDialog(
      context: context,
      builder: (_) => BookingDialog(booking: booking, isProvider: isProvider),
    );
  }
}
