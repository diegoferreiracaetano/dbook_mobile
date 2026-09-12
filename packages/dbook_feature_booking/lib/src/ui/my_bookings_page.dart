import 'package:dbook_core_network/dbook_core_network.dart';
import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../state/booking_providers.dart';
import '../state/booking_record.dart';

final _dateFormat = DateFormat('EEE, MMM d, yyyy · HH:mm');

DbookStatus _toDbookStatus(BookingStatus status) => switch (status) {
  BookingStatus.pending => DbookStatus.pending,
  BookingStatus.confirmed => DbookStatus.confirmed,
  BookingStatus.cancelled => DbookStatus.cancelled,
};

String _statusLabel(BookingStatus status) => switch (status) {
  BookingStatus.pending => 'Pendente',
  BookingStatus.confirmed => 'Confirmada',
  BookingStatus.cancelled => 'Cancelada',
};

/// Reservas feitas nesta sessão (o backend não expõe uma listagem — veja o
/// porquê em [BookingRecord]).
class MyBookingsPage extends ConsumerWidget {
  const MyBookingsPage({super.key});

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    BookingRecord record,
  ) async {
    final confirmed = await showDbookConfirmationDialog(
      context,
      title: 'Cancel Booking',
      message: 'Cancel your seat ${record.seat.label} booking?',
      confirmLabel: 'Cancel Booking',
    );
    if (!confirmed) return;
    if (!context.mounted) return;

    try {
      await ref.read(myBookingsNotifierProvider.notifier).cancel(record);
    } on DbookNetworkException catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookings = ref.watch(myBookingsNotifierProvider);

    return Scaffold(
      appBar: const DbookAppBar(title: 'My Bookings'),
      body: bookings.isEmpty
          ? const DbookStatusPlaceholder(
              icon: Icons.confirmation_number_outlined,
              title: 'Nenhuma reserva ainda',
              message:
                  'As reservas que você fizer nesta sessão aparecem '
                  'aqui.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(DbookSpacing.lg),
              itemCount: bookings.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: DbookSpacing.sm),
              itemBuilder: (context, index) {
                final record = bookings[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(DbookSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${record.flight.originIataCode} → '
                              '${record.flight.destinationIataCode}',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            DbookStatusBadge(
                              status: _toDbookStatus(record.booking.status),
                              label: _statusLabel(record.booking.status),
                            ),
                          ],
                        ),
                        const SizedBox(height: DbookSpacing.xs),
                        Text(
                          '${_dateFormat.format(record.flight.departureTime)} '
                          '· Seat ${record.seat.label}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (record.booking.status == BookingStatus.pending) ...[
                          const SizedBox(height: DbookSpacing.sm),
                          DbookButton(
                            label: 'Cancel Booking',
                            variant: DbookButtonVariant.text,
                            onPressed: () => _cancel(context, ref, record),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
