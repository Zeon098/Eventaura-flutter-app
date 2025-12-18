import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../controllers/booking_controller.dart';
import 'info_row.dart';
import 'status_chip.dart';

class BookingDialog extends StatelessWidget {
  const BookingDialog({
    super.key,
    required this.booking,
    required this.isProvider,
  });

  final BookingModel booking;
  final bool isProvider;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookingController>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.surface],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_note,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'ID: ${booking.id.substring(0, 8)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(status: booking.status),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.calendar_month,
                    label: 'Date',
                    value: DateFormat(
                      'EEEE, MMM d, yyyy',
                    ).format(booking.startTime),
                  ),
                  InfoRow(
                    icon: Icons.access_time,
                    label: 'Time',
                    value:
                        '${DateFormat('h:mm a').format(booking.startTime)} - ${DateFormat('h:mm a').format(booking.endTime)}',
                  ),
                  _ServiceInfoRow(serviceId: booking.serviceId),
                  _UserInfoRow(
                    userId: isProvider
                        ? booking.consumerId
                        : booking.providerId,
                    isProvider: isProvider,
                  ),
                ],
              ),
            ),
            if (isProvider && booking.isPending)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          controller.updateStatus(
                            booking.id,
                            BookingModel.accepted,
                          );
                        },
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'Accept',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          controller.updateStatus(
                            booking.id,
                            BookingModel.rejected,
                          );
                        },
                        icon: const Icon(Icons.cancel_outlined),
                        label: const Text(
                          'Reject',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (isProvider && booking.isAccepted)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      controller.updateStatus(
                        booking.id,
                        BookingModel.completed,
                      );
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text(
                      'Mark Completed',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ServiceInfoRow extends StatelessWidget {
  const _ServiceInfoRow({required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    final serviceRepo = Get.find<ServiceRepository>();
    return FutureBuilder<ServiceModel?>(
      future: serviceRepo.getService(serviceId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return InfoRow(
            icon: Icons.store,
            label: 'Service',
            value: 'Loading...',
          );
        }
        return InfoRow(
          icon: Icons.store,
          label: 'Service',
          value: snapshot.data?.title ?? 'Unknown',
        );
      },
    );
  }
}

class _UserInfoRow extends StatelessWidget {
  const _UserInfoRow({required this.userId, required this.isProvider});

  final String userId;
  final bool isProvider;

  @override
  Widget build(BuildContext context) {
    final userRepo = Get.find<UserRepository>();
    return FutureBuilder<AppUser>(
      future: userRepo.fetchUser(userId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return InfoRow(
            icon: isProvider ? Icons.person : Icons.business,
            label: isProvider ? 'Consumer' : 'Provider',
            value: 'Loading...',
          );
        }
        return InfoRow(
          icon: isProvider ? Icons.person : Icons.business,
          label: isProvider ? 'Consumer' : 'Provider',
          value: snapshot.data?.displayName ?? 'Unknown',
        );
      },
    );
  }
}
