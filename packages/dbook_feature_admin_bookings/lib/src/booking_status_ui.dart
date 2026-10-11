import 'package:dbook_admin_l10n/dbook_admin_l10n.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';

DbookStatus badgeFor(BookingStatus status) => switch (status) {
  BookingStatus.pending => DbookStatus.pending,
  BookingStatus.confirmed => DbookStatus.confirmed,
  BookingStatus.cancelled || BookingStatus.refunded => DbookStatus.cancelled,
  BookingStatus.expired || BookingStatus.unknown => DbookStatus.unknown,
};

class BookingStatusBadge extends StatelessWidget {
  const BookingStatusBadge(this.status, {super.key});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) => DbookStatusBadge(
    status: badgeFor(status),
    label: bookingStatusLabel(context.l10n, status),
    showIcon: true,
  );
}
