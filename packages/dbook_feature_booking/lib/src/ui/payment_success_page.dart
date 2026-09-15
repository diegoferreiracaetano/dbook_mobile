import 'package:dbook_design_system/dbook_design_system.dart';
import 'package:dbook_domain/dbook_domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../booked_leg.dart';
import 'my_bookings_page.dart';

final _priceFormat = NumberFormat.currency(symbol: r'$');

/// Tela cheia de sucesso — mostra depois que o pagamento de todos os
/// trechos é confirmado (substitui a antiga `BookingSuccessPage`, que
/// mostrava uma confirmação por trecho; agora só existe UMA, no final da
/// jornada). "Ver Minhas Reservas" empilha `MyBookingsPage`.
class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({
    super.key,
    required this.payment,
    required this.bookedLegs,
  });

  final Payment payment;
  final List<BookedLeg> bookedLegs;

  @override
  Widget build(BuildContext context) {
    final legLines = bookedLegs
        .map(
          (leg) =>
              '${leg.flight.originIataCode} → '
              '${leg.flight.destinationIataCode} · Seat ${leg.seat.label}',
        )
        .join('\n');

    return Scaffold(
      body: DbookSuccessScreen(
        title: 'Payment Confirmed!',
        message: '$legLines\n\nTotal: ${_priceFormat.format(payment.amount)}',
        referenceLabel: 'Payment reference',
        referenceValue: '#${payment.id}',
        primaryActionLabel: 'View My Bookings',
        onPrimaryAction: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const MyBookingsPage())),
      ),
    );
  }
}
