import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/service_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/service_repository.dart';
import '../../../data/repositories/user_repository.dart';
import 'status_chip.dart';

class BookingCard extends StatelessWidget {
  const BookingCard({
    super.key,
    required this.booking,
    required this.isProvider,
    required this.onTap,
  });

  final BookingModel booking;
  final bool isProvider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 2,
        shadowColor: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white, AppColors.surface.withOpacity(0.3)],
              ),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: _getGradientColors()),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getStatusIcon(),
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat(
                                'EEEE, MMM d',
                              ).format(booking.startTime),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${DateFormat('h:mm a').format(booking.startTime)} - ${DateFormat('h:mm a').format(booking.endTime)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 13,
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
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ServiceNameRow(serviceId: booking.serviceId),
                            const SizedBox(height: 8),
                            _UserNameRow(
                              userId: isProvider
                                  ? booking.consumerId
                                  : booking.providerId,
                              isProvider: isProvider,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getGradientColors() {
    switch (booking.status) {
      case BookingModel.accepted:
        return [const Color(0xFF4FACFE), const Color(0xFF00F2FE)];
      case BookingModel.rejected:
        return [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)];
      case BookingModel.completed:
        return [const Color(0xFF56AB2F), const Color(0xFFA8E063)];
      case BookingModel.cancelled:
        return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
      default: // pending
        return [const Color(0xFFF093FB), const Color(0xFFF5576C)];
    }
  }

  IconData _getStatusIcon() {
    switch (booking.status) {
      case BookingModel.accepted:
        return Icons.check_circle;
      case BookingModel.rejected:
        return Icons.cancel;
      case BookingModel.completed:
        return Icons.verified;
      case BookingModel.cancelled:
        return Icons.block;
      default: // pending
        return Icons.schedule;
    }
  }
}

class _ServiceNameRow extends StatelessWidget {
  const _ServiceNameRow({required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context) {
    final serviceRepo = Get.find<ServiceRepository>();
    return FutureBuilder<ServiceModel?>(
      future: serviceRepo.getService(serviceId),
      builder: (context, snapshot) {
        final serviceName = snapshot.data?.title ?? 'Loading...';
        return Row(
          children: [
            Icon(Icons.store, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                serviceName,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _UserNameRow extends StatelessWidget {
  const _UserNameRow({required this.userId, required this.isProvider});

  final String userId;
  final bool isProvider;

  @override
  Widget build(BuildContext context) {
    final userRepo = Get.find<UserRepository>();
    return FutureBuilder<AppUser>(
      future: userRepo.fetchUser(userId),
      builder: (context, snapshot) {
        final userName = snapshot.data?.displayName ?? 'Loading...';
        return Row(
          children: [
            Icon(
              isProvider ? Icons.person : Icons.business,
              size: 16,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                userName,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
