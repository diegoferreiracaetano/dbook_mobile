import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:flutter/material.dart';

import '../state/booking_record.dart';
import 'my_bookings_page.dart';

/// Tela cheia de sucesso — mostra depois de reservar. "Ver Minhas Reservas"
/// empilha `MyBookingsPage`; "Concluído" volta pro detalhe do voo.
class BookingSuccessPage extends StatelessWidget {
  const BookingSuccessPage({super.key, required this.record});

  final BookingRecord record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DbookSuccessScreen(
        title: 'Booking Confirmed!',
        message:
            'Seat ${record.seat.label} on ${record.flight.flightNumber} is '
            'yours.',
        referenceLabel: 'Booking reference',
        referenceValue: '#${record.booking.id}',
        primaryActionLabel: 'View My Bookings',
        onPrimaryAction: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MyBookingsPage())),
        secondaryActionLabel: 'Done',
        onSecondaryAction: () => Navigator.of(context).pop(),
      ),
    );
  }
}
