import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/service_model.dart';
import '../../booking/controllers/booking_controller.dart';

class BookButton extends StatefulWidget {
  final ServiceModel service;
  final BookingController bookingController;
  final String userId;

  const BookButton({
    super.key,
    required this.service,
    required this.bookingController,
    required this.userId,
  });

  @override
  State<BookButton> createState() => _BookButtonState();
}

class _BookButtonState extends State<BookButton> {
  _BookingSchedule? _lastSchedule;

  Future<_BookingSchedule?> _pickSchedule(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _lastSchedule?.date ?? now;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return null;

    final startInitial =
        _lastSchedule?.start ?? now.add(const Duration(hours: 1));
    final startTod = TimeOfDay.fromDateTime(startInitial);
    final startTime = await showTimePicker(
      context: context,
      initialTime: startTod,
    );
    if (startTime == null) return null;

    final start = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    final endInitial =
        _lastSchedule?.end ?? start.add(const Duration(hours: 1));
    final endTod = TimeOfDay.fromDateTime(endInitial);
    final endTime = await showTimePicker(context: context, initialTime: endTod);
    if (endTime == null) return null;

    final end = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    return _BookingSchedule(date: date, start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.bookingController.isLoading.value
                ? null
                : () async {
                    final schedule = await _pickSchedule(context);
                    if (schedule == null) return;
                    await widget.bookingController.createBooking(
                      serviceId: widget.service.id,
                      consumerId: widget.userId,
                      providerId: widget.service.providerId,
                      date: schedule.date,
                      startTime: schedule.start,
                      endTime: schedule.end,
                      serviceTitle: widget.service.title,
                    );
                    setState(() => _lastSchedule = schedule);
                  },
            child: Center(
              child: widget.bookingController.isLoading.value
                  ? const SizedBox(
                      height: 26,
                      width: 26,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingSchedule {
  const _BookingSchedule({
    required this.date,
    required this.start,
    required this.end,
  });

  final DateTime date;
  final DateTime start;
  final DateTime end;
}
